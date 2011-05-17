LiveResource
============

This is an in-progress framework for resource discovery, operations, and
notifications. I'll update this file when it's more fully baked.

Goals
-----

Terminology -- familiar to Ruby users, not coming from another paradigm like RMI or actors.

To-Do
-----

Enhance remote_writer to allow specification of options (e.g. TTL), something like:

    class C
      include LiveResource::Attribute

      # Existing list notation
      remote_writer :foo, :bar
  
      # Symbol, Hash implies single attribute with options
      remote_writer :baz, :ttl => 10
    end

Enhance subscriber notation, use hash for options:

    class C
      include LiveResource::Subscriber

      # List of symbols implies subscription with callback methods 
      # of the same name.
      remote_subscription :foo, :bar
      
      # Hash (or list of hashes) implies subscriptions with callback
      # methods explicitly specified.
      remote_subscription :baz => :method
    end

Simplify setting the namespace when it's the same for all instances of a class:

    class C
      include LiveResource::Attribute
  
      # Current way to set it (works great for per-instance namespaces):
      def initialize(namespace)
        self.namespace = namespace
      end
  
      # Additional way (would be great for per-class namespace):
      remote_namespace 'foo.bar'
    end

Useful namespace default when none is set explicitly (e.g., pid of current process).

Port all tests from old/state_publisher_test.rb.

Finish rdoc, test to make sure it looks right.

Meaningful examples, e.g. iostat.


