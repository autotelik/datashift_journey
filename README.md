## DataShift Journey

[![Build Status](https://travis-ci.org/autotelik/datashift_journey.svg?branch=master)](https://travis-ci.org/autotelik/datashift_journey)
[![Code Climate](https://codeclimate.com/github/autotelik/datashift_journey/badges/gpa.svg)](https://codeclimate.com/github/autotelik/datashift_journey)
[![Test Coverage](https://codeclimate.com/github/autotelik/datashift_journey/badges/coverage.svg)](https://codeclimate.com/github/autotelik/datashift_journey/coverage)

A Rails software [Wizard](https://en.wikipedia.org/wiki/Wizard_%28software%29)

Quickly create a sequence of forms (dialogs) that lead a visitor through a series
 of defined steps - ideal for questionnaires, application forms, checkouts, surveys, registration processes etc.
                     
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

A concern is added, to hold the journey plan (and avoid cluttering the model too much), that is auto included in the model.

You can edit this concern and configure your required steps in the plan. 

Details of the API are supplied in comments in the file and TODO: <link>

In this example this concern would be located at : `app/models/concerns/checkout_model_journey.rb`
 
An initializer will also be created at : `config/initializers/datashift_journey.rb`
     
Inside the initializer you can change which model to use as the plan.
     
### Defining the Journey Plan

A skeleton journey definition is added to the concern of the plan model.

In here you defines the steps of the apps journey and set the initial step.

Here's a simple example for a basic checkout, on an ActiveRecord model, `Checkout`

```ruby
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
```
    
A state machine will be generated with all steps starting at :ship_address and finishing at :complete,
and forward and backwards navigation between them.

> *A view partial and associated form, will be expected for each state.*

### Views

Each step will need a view, usually a form to collect information from, but can be a static page or any content you like really.
 
A **generator** is provided to create these associated views for you, one per state(page).

Once you are happy with your journey plan run :

```bash
 rails generate datashift_journey:views
```

### View Forms

You can use the Forms pattern to back a view. These tend to do the work traditionally performed in the Controller, 
such as managing presentation data required for a view, managing params, validating and saving the data entered into forms. 
 
A **generator** is provided that can create skeleton Forms fro you, one per state(page).

Options
 
>   [--base-class=ClassName] # Class to use as the Base class for generated Forms

```bash
 rails generate datashift_journey:forms
```
Generated Forms derive from `datashift_journey/app/forms/datashift_journey/base_form.rb` 
 
And ultimately from Reform::Form - see - https://github.com/trailblazer/reform
 
### Data Collection
Ultimately the views and forms are there to collect data from a User, validate and store it.

Generate and use associated backing Reform forms to validate and store data, collected from your visitors.
      
The Reform form expects to be backed by a model, and can write data back to the model via sync and save methods,
enabling you to populate the data however you choose within your Forms - see section 'Custom Data Collector'

Alternatively a generic SQL based data collector is provided for use with the generic generated Forms to save the data.

### Data Collector
 
This setup will collect data as a series of nodes, essentially keyed on the form name (state), 
and holding field name/value pairs i.e one database row per question/answer.

To use this concern as your main data collection agent, simply run the installer

```ruby
rails generate datashift_journey:collector
```

This will copy over concern, relevant migrations and decorate the journey plan class.

For simplified access to this model in your forms, derive from `DatashiftJourney::BaseCollectorForm`.

>>>>>
This base class provides access to the current journey plan via a `collector` alias, 
and the 'save' method this will create a single new node entry. ~

Currently if your form contains multiple questions you must over ride save yoursefl
 
 TODO Base class that can process multiple fields
>>>>>>>>>>
>
#### Example saving fields

```ruby
  property :company_name, virtual: true
  property :postcode, virtual: true

  def save
     
      collector.data_nodes << DatashiftJourney::DataNode.new(
        form_name: 'BusinessDetailsForm',
        field: 'company_name',
        field_presentation: company_name.titleize,
        field_type: 'string'
      )

      collector.save
    end
```
 
To access a form entry there are helpers such as find the value for a form and field

```ruby
    collector.field_value_for("BusinessTypeForm", "business_type")
```

### Mongo Data Collector
 
 # TODO
 
An optional MongoDB based Collector is under development, which will collect data in a single document per journey.

To use this model as your main JourneyPlan model, simply run the installer to setup the model.

```ruby
rails generate datashift_journey:install_mongo_collector
```

See below for details of using your own models instead.

### Custom Data Collector

To ensure all helpers etc are available throughout, either inherit from our controller

```ruby
class ApplicationController < DatashiftJourney::ApplicationController
```
Or in your ApplicationController pull in our engines helpers

```ruby
  helper DatashiftJourney::Engine.helpers
```
  




#### Naming conventions

> The Classified version of the state name, plus "Form", so a `:billing_address` state should be backed
by a form called `BillingAddressForm`

The DSJ Controller will search for a matching Form for each state using the Factory class/method

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
    
There are a couple of base classes available, that will do most of the Form work, if you inherit from them.

When using the DSJ Collection models, you can derive from `DatashiftJourney::BaseCollectorForm`.

When using your own model use `DatashiftJourney::BaseForm` .
    
The Form must have a factory method, and a constructor that expects a JourneyPlan model instance.

For example

```ruby
    # Default factory using our basic Collector model
    def self.factory(collector)
      new(collector)
    end
```  
  
Once the Form class has been identified the Controller will attempt to create the new form object
passing in the current journey plan object.

The visibility of the default continue or submit button is driven by the 'show_submit_button?`
method on your Form. If you are deriving from DatashiftJourney::BaseForm this is already implemented
to return true by default.

Over ride and return false if you wish to **hide** the button.

```ruby
 def show_submit_button?
    false
 end
```

### The Views

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

See The Form to configure visibility of the default continue or submit button.

### DatashiftJourney::Collector

This option uses DatashiftJourney::Collector as the journey plan class, which stored  the data collected,
 from each state/page in  `collector_data_nodes`

This collection is a series of `DatashiftJourney::DataNode` objects.

When there's a single field on a page to collect, you can inherit from the BaseCollectorForm
and your state form becomes very simple, for example

```ruby
class OtherBusinessesForm < DatashiftJourney::BaseCollectorForm

  def params_key
    :other_businesses
  end

  property :field_value

  # basic validation - has field been filled in
  validates :field_value, presence: true

end
```

Collected data will be stored as a `DatashiftJourney::DataNode` field name is the **underscore** name of the state
for example given a state BusinessTypeForm, a From BusinessTypeForm, the field name is 'business_type'

For example

```ruby
DatashiftJourney::DataNode
    id: 5,
    form_name: "BusinessTypeForm",
    field: "business_type",
    field_presentation: "Business Type",
    field_type: "string",
    field_value: "sole_trader"
```

In Rails form tags within the viwe/partial, the object_name to use is 'field_value'

For example, to select a single field from set of radio buttons :

```ruby
    <%= f.label :field_value, for: "registration_field_value_soletrader",  class: 'block-label' do %>
      <%= f.radio_button :field_value, 'sole_trader' %>
      <%= t '.sole_trader' %>
    <% end %>
    <%= f.label :field_value, for: "registration_field_value_partnership",  class: 'block-label' do %>
      <%= f.radio_button :field_value, 'partnership' %>
      <%= t '.partnership' %>
    <% end %>
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
