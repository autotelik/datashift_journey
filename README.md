## DataShift Journey

[![Build Status](https://travis-ci.org/autotelik/datashift_journey.svg?branch=master)](https://travis-ci.org/autotelik/datashift_journey)

Define a Forms based journey through your site, such as a questionnaire, checkout, survey, registration process etc
using a state machine based DSL.

Provides a generic Controller, Views and data collection model (for storing form data), and manages navigation for you.
 
If you prefer, you can easily provide your own ActiveRecord  data collection model, and still use the same
 state machine based DSL.

This DSL provides high level syntactic sugar to program the steps or pages through your site.

Generators are provided that can generate skeleton views and backing Reform forms for each step.

Forward and back navigation, through the different paths, is automatically generated, via state machine transitions.

The routes through the site can split multiple times, down different branches, based on values collected,
and can reconnect later to common sequences.

The main underlying gems we use include :

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
    
## Setup and Configuration - Initializer

DatashiftJourney needs a parent or collector model, through which all the data can be collected hangs.
The concept is like an Application, Checkout, Registration, Enrollment etc.

This model is the entry point into any individual journey, so it is decorated with the state engine, and 
therefor contains the journey steps, but also has columns or associations to store all the data collected
on each step.


### Generic Data Collector
 
A generic Collector is provided out of the box, with the collected data stored on a per step basis,
in an associated generic key/value type store. The usage within the forms and views is detailed further below. 

Using these classes is optional, see next section to use your own models, but to use these DSJ models, 
simply run the installer - which will copy over relevant migrations etc.

```ruby
rails generate datashift_journey:install_collector
```

### Custom Data Collector

Alternatively you can provide your own journey class, for example, you may have an existing Checkout class you want
to use, collecting data as visitors progress through the checkout, such as associated address and payment data.

DSJ needs to be informed of this model class, via an initializer.

A **generator** is provided to create this for you. For example, to use your model called `Checkout`

```ruby
rails generate datashift_journey:initializer --journey_class Checkout
```

Creates the file `config/initializers/datashift_journey.rb`

This model will be auto-decorated with an association to a state machine.

This model can be an existing model, or created from scratch, but it's **vital** that this journey class
 has a string column called `state`
 
If the model does not yet exist, the initializer will create a basic migration for you containing this
 
If you need to add an associated migration yourself it should contain `t.string :state` e.g 

```ruby
rails generate "migration", "AddStateToMyModel", "state:string"
```

To ensure all helpers etc are available throughout, either inherit from our controller

```ruby
class ApplicationController < DatashiftJourney::ApplicationController
```

Or in your ApplicationController pull in our engines helpers

```ruby
  helper DatashiftJourney::Engine.helpers
```
  
### Routes

The initializer will add the following routes to your app's `config/routes.rb` file. 

You will want to edit/remove the root if you intend the home page to be different from the initial state.

Then you can link from any page to the start of the journey via url helper `new_journey_plan`

```ruby
Rails.application.routes.draw do
  mount DatashiftJourney::Engine => "/dj"

  root to: "datashift_journey/journey_plans#new"
end
```

### Define the journey

A skeleton journey definition is added by the initializer to a concern of the supplied model.

If using the DSJ Collector this will be

`app/decorators/datashift_journey/collector_decorator.rb`

If using your own model, for example Checkout, this will be

`app/models/concerns/checkouts_journey.rb`

In here you can plot the details of your site journey and set the initial: step.

Here's a simple example for a basic checkout, on an ActiveRecord model, `Checkout`

```ruby
  MachineBuilder.create_journey_plan(initial: :ship_address) do
  
      sequence [:ship_address, :bill_address]

      # first define the sequences
      split_sequence :visa_sequence, [:visa_page1, :visa_page2]

      split_sequence :mastercard_sequence, [:page_mastercard1, :page_mastercard2, :page_mastercard3]

      split_sequence :paypal_sequence, []

      # now define the parent state and the routing criteria to each sequence

      split_on_equality( :payment,
                         "payment_card",    # Helper method on Checkout that returns card type from Payment
                         visa_sequence: 'visa',
                         mastercard_sequence: 'mastercard',
                         paypal_sequence: 'paypal'
      )

      # All branches recombine here at review
      sequence [:review, :complete ]
  end
```
    
The state machine will generate a series of states (steps) starting at :ship_address and finishing at :complete,
and also forward and backwards navigation between them.

A view partial and associated form, will be expected for each state.


### The Forms

The Forms tend to do work traditionally performed in the Controller, such as managing data required for a view,
managing params, validating and saving the data entered into the HTML form. 

**Generators are provided that can create skeleton Forms and Partials, one per state(page).**

```bash
rails generate datashift_journey:forms

rails generate datashift_journey:views
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

When usign the DSJ Collection models, you can derive from `DatashiftJourney::BaseCollectorForm`.

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

### State Jumper Toolbar

There is a development toolbar available for creating and jumping straight to any State

This is not available in production and must be activated by setting 

```ruby 
config.add_state_jumper_toolbar = true
```
  
So that any data required for previous states can be created, it supports passing in a Factory
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
