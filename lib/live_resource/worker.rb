class LiveResource
  class Worker
    EXIT_TOKEN = 'exit'
    
    def initialize(resource)
      @resource = resource
      @name = resource.name
      @redis = resource.redis
      @actions = resource.actions
      @thread = Thread.new { self.main }
    end

    # List of pending actions, new action tokens pushed on the left side:
    #   [ 1236, 1235, 1234 ]
    # Take one off the right side (blocking operation), reference the
    # token for it of the form:
    #   name.actions.1234.method => YAML-ized method
    #   name.actions.1234.params => YAML-ized parameters
    
    def main
      trace "Worker thread starting"
      
      loop do
        list, token = @redis.brpop "#{@name}.actions", 0
        trace "Worker thread popped token #{token}"
        
        return if token == EXIT_TOKEN

        method = hget token, :method
        params = hget token, :params
        
        if @actions.has_key? method
          proc = @actions[method]

          begin
            value = proc.call(params)
            hset token, :result, value
          rescue Exception => e
            hset token, :result, e
          end
        else
          hset token, :result, 
            RuntimeError.new("Worker does not respond to #{method}")
        end
      end
      
      trace "Worker thread exiting"
    end
    
    private
  
    def hash_for(token)
      "#{@name}.actions.#{token}"
    end
    
    def hsetnx(token, key, value)
      trace("hsetnx #{hash_for(token)} #{key}: #{value}")
      @redis.hsetnx(hash_for(token), key, YAML::dump(value))
    end
    
    def hset(token, key, value)
      trace("hset #{hash_for(token)} #{key}: #{value}")
      @redis.hset(hash_for(token), key, YAML::dump(value))
    end
    
    def hget(token, key)
      trace("hget #{hash_for(token)} #{key}")
      value = @redis.hget(hash_for(token), key)
      trace(" -> #{value}")
      YAML::load(value)
    end

    def trace(s)
      @resource.trace(s)
    end
  end # class Worker
end # class LiveResource