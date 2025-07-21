# GbcTrestleModifier

## Disclaimer

Before you start using this generator, a disclaimer.

This is an extremely opinionated way of doing things in Trestle. It is the way I organize my projects using Trestle because I find it easier to work with.

I plan on adding new features to it over time, but for now, I am not planning on major updates or anything along those lines.

## Introduction

[Trestle](https://trestle.io/) is a great tool for rapidly prototyping projects. I use it in loads of my projects. There are a couple of things that kind of tick me off, though:

### Large resource files

Trestle resources tend to become large files in the `app/admin` folder due to the way they are written.  
I find it hard to read/maintain them as one big file, so I split them up into smaller files and created a generator to ensure that they always follow a standard.

### Complex menu administration

Another pet peeve is the menu handling. Handling menu items in each resource quickly becomes a nightmare. Ordering them requires a lot of manual work.

To keep things simpler, inspired by the work from the crowd at [WinterCMS](https://wintercms.com),  
I created a `menu.yml` file that is used to manage the menu. I also created a helper that simplifies the placement of the menu.

## Splitting up Resources

### Using the generator

```bash
rails generate gbc:trestle:resource my_resource [ModelName]
```

You basically run this at the root of your Rails project and the generator will create all the necessary files for you to start customizing.

#### my_resource

This is the admin name. The convention is that you name it as the pluralized version of your model, so if you have a model called `Category`, you would name it `categories`.  
This is the name of the Trestle resource.

#### ModelName - optional

If you are going to call your resource something else, like `manage_categories` (which I personally like to do), then you'll need to pass along the base model that this resource works with.

To illustrate:

```bash
rails generate gbc:trestle:resource manage_categories Category
```

This will generate a functioning resource called `manage_categories` that uses `Category` as its base model.

### Basic understanding

To keep things easy to read in Admin, I create a folder with the resource name and create files for: Controller, Form, Table, and Routes.  
Each file works pretty much the same way they do in a Trestle resource.

Where in a Trestle resource you'd have something like this:

```ruby
Trestle.resource(:my_resource) do
  # ... 
  table do
    column :name
    column :created_at, align: :center
    actions
  end
  # ...
```

Your `my_resource/table.rb` would have something like:

```ruby
module TargetSites
  class Table
    def initialize(base)
      @base = base
    end

    def render
      @base.table do # <-- this is the table method for our resource
        column :name
        column :created_at, align: :center
        actions
      end
    end
  end
end
```

Basically, everything you would do in your `table do` block in your resource, you now do in your `@base.table do` block inside your `my_resource/table.rb`.

### Tables, Forms, and Routes

All follow the same pattern. Again, I am not planning on reinventing the way Trestle works; I am just making my life easier.  
When you have complex tables, complex forms, and the need for several controllers and routes in a resource, I find working in separate files much easier.

### Controllers - the exception

Controllers follow a slightly different model. Instead of instantiating a class, we just need to define our methods in the module.

Let's say I want to override the `index` method on my resource.

In a regular Trestle resource, we'd do:

```ruby
controller do
  def index
    render json: 'Overwrite index for example'
  end
end
```

With the split-up files, you'd edit your `my_resource/controller.rb` like this:

```ruby
module MyResource
  module Controller
    def index
      render json: 'Overwrite index for example'
    end
  end
end
```

### How does this all work?

Basically, I inject into the resource file the loaders for each of these files.

```ruby
# frozen_string_literal: true

Trestle.resource(:my_resource) do
  menu do
    item :my_resource, icon: "fa fa-star", badge: "FIX MENU.YML"
  end

  # All your configurations are in folder app/admin/my_resource
  #
  # DO NOT CHANGE THINGS FROM HERE ON 
  # BLOCK 1
  resource_dir = File.expand_path("my_resource", __dir__)
  components = %w[table form controller routes]

  components.each do |component|
    file_path = File.join(resource_dir, "#{component}.rb")
    if File.exist?(file_path)
      require_relative file_path
      class_name_segment = component.camelize # Converts 'table' to 'Table'
      full_class_name = "MyResource::#{class_name_segment}"

      if (klass = full_class_name.safe_constantize) && klass.respond_to?(:new) && klass.instance_methods.include?(:render)
        klass.new(self).render
      end
    end
  end

  # Call methods into controller
  # BLOCK 2
  controller do
    include MyResource::Controller
  end
end
```

In **BLOCK 1** — which you should never need to edit:

We load the files from the folder.  
If they have a `render` method (which they should), we call it, passing in our current resource — essentially injecting our table/form/controller/etc. functionality into our resource.

In **BLOCK 2** — we are including the methods into our controller definition.

## Easy menu administration

### The problem

Menus in Trestle are great, but they quickly become a nightmare if you are moving things around.  
This is in part due to the atomic nature of how we declare them. In each resource, you specify which group, which position (and so on) this menu item must be in.

When you have dozens of menus, adding a new group or changing the order of a menu item requires you to painstakingly go through all the resources and adjust menu entries.

### The solution

Rather than declaring the menus in each resource, I created a helper and a YAML file that allow you to centralize menu administration. (This was inspired by the work from the crowd at [WinterCMS](https://wintercms.org)).

#### The `menu.yml`

Central to menu administration — this is where you structure your menu.

```yaml
group1:
  label: 'Group 1'
  priority: 1
  items:
    item1:
      url: '/admin/admin1'
      label: 'Group 1 - Menu Item 1'
      icon: 'fa-speak'
      priority: 1
    item2:
      url: '/admin/admin2'
      label: 'Group 1 - Menu Item 2'
      icon: 'fa-home'
      priority: 2
      target: '_blank'
      badge:
        text: 'Externo'
        type: 'warning'
group2:
  label: 'Group 2'
  priority: 2
  items:
    item1:
      url: '/admin/admin3'
      label: 'Group 2 - Menu Item 1'
      icon: 'fa-speak'
      priority: 1
    item2:
      url: '/admin/admin4'
      label: 'Group 2 - Menu Item 2'
      icon: 'fa-home'
      priority: 2
      target: '_blank'
      badge:
        text: 'Externo'
        type: 'warning'
```

OK — I agree that looks complex, but it's pretty straightforward when you look at it.

- I have two groups: `group1` and `group2`
- Each group has two `items`
- Groups have a `priority` (which determines the order of the groups — lower comes first)
- Items also have a `priority` — this orders the items inside the group

The rest of the parameters are pretty much the same as the parameters you can pass into a Trestle menu and menu item.

#### The helper

Now instead of declaring your menu item directly in your resource, you just say what YAML item this resource points to:

```ruby
menu do
  Trestle::MenuHelper.new(
    self,
    "group1",
    "item2"
  ).render_menu
end
```

This would render `item2` of `group1`.

### What does this allow?

Well, now that you are no longer declaring positions and groups directly in your resources, most of your changes to menu ordering will happen in your `menu.yml` file.

For example, if you wish to make `item2` of `group1` the first item in the list, all you have to do is change the priorities in the YAML file.

## In the future

I plan on adding more separation — splitting Scopes, Collections, and Search into their own files. I haven't yet, because most of my resources have small, simple declarations that are easy to manage.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/GregoryBrownConsultancy/gbc_trestle_modifier.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
