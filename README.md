## DataShift Journey

[![Build Status](https://travis-ci.org/autotelik/datashift_journey.svg?branch=master)](https://travis-ci.org/autotelik/datashift_journey)
[![Code Climate](https://codeclimate.com/github/autotelik/datashift_journey/badges/gpa.svg)](https://codeclimate.com/github/autotelik/datashift_journey)
[![Test Coverage](https://codeclimate.com/github/autotelik/datashift_journey/badges/coverage.svg)](https://codeclimate.com/github/autotelik/datashift_journey/coverage)

A Rails software [Wizard](https://en.wikipedia.org/wiki/Wizard_%28software%29)

Quickly create a sequence of forms (dialogs) that lead a visitor through a series
 of defined steps - ideal for questionnaires, application forms, checkouts, configurations, surveys, registration processes etc.
                     
Provides a simple DSL to quickly define a multi page journey through your site,
including complex branching, and rejoining, dependent on collected values.

State is maintained in one of the backends, with different storage models being provided
 out of the box, or use your own model structure.

Full server-side processing can be delayed until the submission of the final form.

The DSL provides a simplified layer on top of a State Machine, with the main underlying gems being :
 
 * https://github.com/state-machines/state_machines
 * https://github.com/state-machines/state_machines-activerecord
 * https://github.com/apotonick/reform
 
## Getting started
 
 This is a Rails engine so simply add this line to your application's Gemfile:
 
 ```ruby
 gem 'datashift_journey', git: 'https://github.com/autotelik/datashift_journey'
 ```
 And then execute:
 
     $ bundle install
 
DatashiftJourney needs a model on which to store the Wizard or Journey Plan through a state machine definition.
     
See below if you already have model you wish to decorate.
     
If you're starting from scratch, a **generator** - `rails generate datashift_journey:setup` - is provided to setup everything for you.

For example, to create a Checkout model, that will collect the data entered during a checkout journey, 
such as confirm order, billing address, shipping address and payment data.
 
```ruby
    rails generate datashift_journey:setup Checkout 
```
   
This will generate a number of files, including a model file, migration to create the model table with a single column called `state`
>If using an existing model, it's **vital** that this journey class has a string column called `state`
   i.e If you need to add an associated migration yourself it should contain `t.string :state`

In this example this model would be located at : `app/models/checkout.rb`

A stub for entering the journey plan is added to the model.

You should edit this model and configure your required steps in the plan. 

Details of the API are supplied in comments in the file and TODO: <link>
 
An initializer will also be created at : `config/initializers/datashift_journey.rb`
     
Inside the initializer you can change which model to use as the plan and set various configuration options.
     
### Defining the Journey Plan

A skeleton journey definition is added as a comment seciton to the plan model.

In here you defines the steps of the apps journey and set the initial step.

Here's a simple example for a basic checkout, on an ActiveRecord model, `Checkout`

```ruby

class Checkout < ApplicationRecord

  DatashiftJourney::Journey::MachineBuilder.create_journey_plan(initial: :ship_address) do
  
      # Two simple sequential steps
      sequence [:ship_address, :bill_address]

      # At the next step, we will have a branch so first define the branch nodes - they also can 
      # be sequences of multiple steps, a single step, or nothing (skip straight to branch recombination step) 
      branch_sequence :visa_sequence, [:visa_page1]

      branch_sequence :mastercard_sequence, [:page_mastercard1, :page_mastercard2]

      branch_sequence :paypal_sequence, []

      # Define the next state (after :bill_address, and parent state of the branch) 
      # and the routing criteria to each sequence
      # So after bill address we reach payment - then we split to a single step, depending on the card type entered

      split_on_equality( :payment,
                         "payment_card",    # Helper method on Checkout that returns card type from Payment
                         visa_sequence: 'visa',
                         mastercard_sequence: 'mastercard',
                         paypal_sequence: 'paypal'
      )

      # All different card type branches, recombine here at review
      sequence [:review, :complete ]
  end

....
```
    
A state machine will be generated with all steps starting at :ship_address and finishing at :complete,
and forward and backwards navigation between them.

> *A backing Reform style Form and associated view partial, will be expected for each state.*

### View Forms

The default controllers expect the Forms pattern to back each view. 

DSJ includes the Reform gem and utilises their Form - see - https://github.com/trailblazer/reform
                                             
These tend to do the work traditionally performed in the Controller, so our controller can stay generic
and focused on navigation.

Forms give you the flexability to implement your own strategies for dealing with the presentation data required for a view, 
managing params, validating entreed values, and saving the data entered into forms. 
 
A **generator** is provided that can create skeleton Forms for you, one per state(page).

Options
 
>   [--base-class=ClassName] # Class to use as the Base class for generated Forms

```bash
 rails generate datashift_journey:forms
```
Generated Forms derive from `datashift_journey/app/forms/datashift_journey/base_form.rb` 
 
And ultimately from Reform::Form
 
### Views
 
 Each step will need a view, usually a form to collect information from, but can be a static page or any content you like really.
  
 A **generator** is provided that can create a starter set of partial views for you, one per state(page).
 
 So, once the journey plan has been fully defined run :
 
 ```bash
  rails generate datashift_journey:views
 ```
 
 The Controller will expect a view partial, for each related Form.
 
 The partials are rendered passing in the Form as a local variable.
 
 The location of the partial to use for a certain state is given by helper
 
           def journey_plan_partial_location( state )
 
 The default is `app/views` but path can be changed using Configuration option `partial_location`
 
 This will be required in the path format, if you are using multiple namespaces/folders
 
 ```ruby
    DatashiftJourney::Configuration.configure do |config|
      config.partial_location = "checkout_engine"
    end
 ```
### Data Collection
Ultimately the views and forms are there to collect data from a User, validate and store it.

Generate and use associated backing Reform forms to validate and store data, collected from your visitors.
      
The Reform form expects to be backed by a model, and can write data back to the model via sync and save methods,
enabling you to populate the data however you choose within your Forms - see section 'Custom Data Collector'

Alternatively a generic SQL based data collector is provided for use with the generic generated Forms to save the data.

### Data Collector
 
This setup will add a migration, creating a number of tables to manage the collection of data, on a form by form basis,
 stored as a series of nodes, essentially keyed on the form class and name (state).
 
The journey plan class is decorated with an association the the data nodes, so each instance of the journey holds all the data for that joureny,
as a collection of fields (name/value) i.e one database row per question/answer.

To use this concern as your main data collection agent, simply run the installer

```ruby
rails generate datashift_journey:collector
```

This will create relevant migrations and decorate your journey plan class with data collection attributes.

To access manually, derive your form from `DatashiftJourney::Collector::BaseCollectorForm`.

### Mongo Data Collector
 
#### TODO
 
An optional MongoDB based Collector is under development, which will collect data in a single document per journey.

To use this model as your main data collection class, simply run the installer to setup the model.

```ruby
rails generate datashift_journey:install_mongo_collector
```

#### Journeys End

The controller should identify when the last state has been submitted and there are no further states to be rendered.

After processing the last state, the controller will redirect to the JourneyEndsController and its default new view will be rendered.

To provide your own end page, in your app simply override this view - `app/views/datashift_journey/journey_ends/new.html.erb`

You can also implement an `on_journey_end` hook, in your JourneyPlan class, which will be called by the controller
(if implemented) **before** the view is rendered.

For example, you can spin off jobs that parse and process the data

```ruby
class Checkout < ApplicationRecord
  def on_journey_end
    Apoc::CreateOrderWorker.perform_async(self.id)
  end
```

#### Internals

> The Classified version of the state name, plus "Form", so a `:billing_address` state should have an associated form called `BillingAddressForm`

The DSJ Controller will search for a matching Form for each state using the Factory class/method

## OUT OF DATE
```ruby
DatashiftState::FormObjectFactory.form_object_for(journey_plan)
```

In code, the expected form Class name is defined as  :

```ruby
"#{modules}::#{journey_plan.state.classify}Form"
```

When using namespaces the *module* structure , can be set via the DSJ Configuration object,
which can be set, using a standard block format, in an initializer, as so:

```ruby
DatashiftJourney::Configuration.configure do |config|
  config.forms_module_name = 'MyCheckoutEngine'
end
````

So given a module name configuration setting of

```ruby
MyCheckoutEngine::States
```

And a current state of :address - then the Controller will attempt to use Form class

```ruby
MyCheckoutEngine::States::AddressForm
```
## END OUT OF DATE

#### Null Forms

When **no form** is required for a specific HTML page, you an specify that NullForm is to be used,
either globally for ALL missing forms, or for specific named forms.

The null form means no params are validated, and no save performed, for example for a mid sequence, text only
 helper page, or for a text only branch terminating page.

To set globally

```ruby
DatashiftJourney::Configuration.configure do |config|
  config.use_null_form_when_no_form = true
end
```

To set for individual states, with no data collection requirements, add to list of `null_form` states

```ruby
DatashiftJourney::Configuration.configure do |config|
  config.null_form_list = [:confirm_page_with_no_data, :brexit]
end
```

### DatashiftJourney::Collector

This option uses the journey plan class itself to store the data collected from each state/page in `data_nodes`

This collection is a series of `DatashiftJourney::Collector::DataNode` objects.

The generator will geneate a series of forms that inherit from `DatashiftJourney::Collector::BaseCollectorForm`
and your state form becomes very simple, for example

```ruby
class ResourcesForm < ::BaseForm
  journey_plan_form_field name: :namespace, category: :string
  journey_plan_form_field name: :number_of_cpu, category: :number
  journey_plan_form_field name: :memory, category: :number
end
```

This will create field definitions, which can then be rendered automatically using the default views,
and on submit, the data entered will be saved to the DB as a DataNode, one per field name

```JSON
DataNode: {
    "id":8, 
    "form_field_id": 1,
    "field_value": "My New Namespace"
  }
```

### Routes

The generator will add the engines routes to your app's `config/routes.rb` file. 
You can manually change the mount point to whatever suits your application.

```ruby
Rails.application.routes.draw do
    mount DatashiftJourney::Engine => "/"
end
```

If youd like to set your apps root to be the initial state, you can manually add the following :

```ruby
Rails.application.routes.draw do
    root to: "datashift_journey/journey_plans#new"
end
```

### State Jumper Toolbar

There is breadcrumb style toolbar available for creating and jumping straight to any State

This must be activated by setting 

```ruby 
config.add_state_jumper_toolbar = true
```

In development, so that any data required for previous states can be created, it supports passing in a Factory
that creates that data for you.

The factory should return an instance of your DatashiftJourney.journey_plan_class

Configure your list of required 'jump to' states and factories -  where no factory required simply pass nil -
by setting `state_jumper_states`, for example

```ruby 
config.state_jumper_states = {contact: my_contact_factory, ship_address: nil, :bill_address: nil}
```
    
The view is added to a content_for block called :datashift_journey_state_jumper 
so you can add this somewhere in your layout.

To pull in some default styling add following to your `application.css.scss`

`@import 'datashift_journey/partials/state_jumper_toolbar';`

## License

Author ::   Tom Statter

Date ::     April 2016

The MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
