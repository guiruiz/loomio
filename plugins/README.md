# Plugin architecture for Loomio! (a work in progress)

Due to popular demand, we've implemented a simple plugin architecture to allow contributors to supply their own awesome improvements to Loomio. This is a great place to start!

## Setting up a plugin
Every plugin must be a folder within the `/plugins` directory, with a `plugin.rb` file in it. Like so:

```
/plugins
  /kickflip
    plugin.rb
```

As we'll see, other files may go into this directory, but this is the bare minimum for a working plugin.

### Writing your plugin.rb

In your `plugin.rb` file, write a class which inherits from `Plugins::Base` (this will give you access to the setup method). It's also usually a good idea to namespace your plugin within a module, so there aren't naming conflicts.

Within this class, you'll want to write a setup method, like so:

```ruby
module Plugins
  module Kickflip
    class Plugin < Plugins::Base
      setup! :kickflip do |plugin|
        # your plugin code goes here
      end
    end
  end
end
```

This setup method takes the name of your plugin, and a block of actions to perform to set it up.

### Enable and disable plugins via ENV
One of the first things to do with a new plugin is specify how it is enabled.
Within the aforementioned setup block, you can put a line in like so:

```ruby
setup! :kickflip do |plugin|
  plugin.enabled = "KICKFLIP_ENABLED"
end
```

This will look in your ENV for a `KICKFLIP_ENABLED` value, and enable your plugin if that value is present.
To ensure that a plugin is always enabled, you can also set this value to `true`:

```ruby
  plugin.enabled = true
```

### Add new classes
Let's include an external class into our plugin. Inside our plugin folder, we write a `Kickflip` class, into `plugins/kickflip/models/kickflip.rb`:

```ruby
class Kickflip
  def perform
    puts "100 points!"
  end
end
```

Then, in order to include this class, we can write the following line into our setup block:

```ruby
  plugin.use_class 'models/kickflip'
```

We spin up our Loomio instance, and voila!
```
> Kickflip.new.perform
100 points!
```

### Add directories of classes
You can also include entire directories of classes if you don't want to type out every single file

```ruby
  plugin.use_class_directory 'models'
```
(note that this is not recursive)

### Extend existing classes
If you want to extend an existing class, you can do so easily! Here we use the `extend_class` command, and pass it a constant. Then we can write additional functionality onto existing classes within a block
(this is executed onto the given class using `class_eval`)

```ruby
  plugin.extend_class User do
    def kickflip
      puts "100 points!"
    end
  end
```
(note that this will overwrite existing methods in the class; be careful!)

```
> User.new.kickflip
100 points!
```

### Listen for Loomio events
Loomio emits all kinds of events as things happen within the app. Most service methods (the files living in `app/services`) will emit events, as well as when new Event instances are created (`app/models/events`). In order to listen to these events, you can use the `use_events` method, which will supply you an instance of our EventBus to
apply listeners to.

Parameters passed through these events vary a little based on the event, but the following rules of thumb apply:

**For Service Calls**: (|model, user, params|) The model being worked on is passed through (so, for a discussion service call, the discussion in question would be passed through), followed by the user performing the action, and the parameters passed to the service, if they exist. Again, you can check out the source for the service in question (`app/services`) for more info on what specifically is passed through for each event.

**For Event creation**: (|event, user|) The newly created event is passed through, followed by the user performing the action.


```ruby
  plugin.use_events do |event_bus|
    event_bus.listen('new_motion_event') { |motion| Kickflip.new(motion).perform }
  end
```
Here we listen for whenever a new motion is created, build a new Kickflip with it, and call perform on it.

### Add angular components
Much of the javascript app is written using Angular components, which are reusable directives accompanied by a template and stylesheet. You can check them out in `lineman/app/components`. A kickflip component might look like this:

```
/plugins
  /components
    /kickflip
      kickflip.coffee
      kickflip.haml
      kickflip.scss  
```

We highly recommend sticking to this structure for plugins as well.

### Attach code to outlets in the Angular interface
(not working yet)

### Add database migrations
(not working yet)

### Add tests