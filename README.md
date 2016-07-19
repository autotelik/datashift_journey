## DataShift Journey

[![Build Status](https://travis-ci.org/autotelik/datashift_journey.svg?branch=master)](https://travis-ci.org/autotelik/datashift_journey)

Define a journey through your site, via a simple state based DSL, provides a generic Controller that
manages navigation for you, collect data via a forms based approach. 

Take any ActiveRecord model and add a state machine that manages a multi-page journey
such as a questionnaire, checkout, survey, registration process etc

Provides high level syntactic sugar to program the journey steps, and manage the views and underlying forms.

Forward and back navigation through the different paths is automatically generated.

The paths can split, based on values collected or provided by user, and can reconnect later.

The underlying gems we are using :

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
    
## Setup and Configuration

The app must inform datashift_journey of the model, that hosts the journey plan and stores data collected on the journey.

So this is the parent model off which all the data to be collected should hang, the concept is like a 
Checkout, Registration or Enrollment.

Inform datashift of the name of this class via an initializer

For example, in `config/initializers/datashift_journey.rb`
    
```ruby
  DatashiftJourney.journey_plan_class = "Checkout"
```

This journey model will be decorated with an association to the state machine.

This can be an existing model, or created from scratch, but it's vital that your journey class
 has a string column called state i.e
 
 For example to create this model from scratch the associated migration should contain `t.string :state` e.g 

```ruby
class CreateCheckouts < ActiveRecord::Migration
  def change
    create_table :checkouts do |t|
      t.string :state
      t.timestamps null: false
    end
  end
end
```

### Routes

Add the engine routes into your main apps config/routes.rb file. 

You can set the home page to point to the initial state by setting a root path as per this example

```ruby
Rails.application.routes.draw do
  mount DatashiftJourney::Engine => "/dj"

  root to: "datashift_journey/journey_plans#new"
end
```

Otherwise you can create a link from any page to the start of the journey via url helper `new_journey_plan`


### Define the journey

The journey definition should be added within the model class itself, either directly in the file or to keep it
uncluttered, in a concern or decorator for that model class.

Here's a simple example for a basic checkout, on an ActiveRecord model, `Checkout`

```ruby
class Checkout < ActiveRecord::Base

    DatashiftJourney::Journey::MachineBuilder.build(initial: :ship_address) do

        sequence [:ship_address, :bill_address]

        split_on_equality( :payment,
                           "payment_card",                                # The helper method on Checkout, returns card type from Payment
                           [:visa_page, :mastercard_page, :paypal_page],  # Target pages
                           ['visa', 'mastercard', 'paypal'])              # Value to trigger target

        split_sequence :visa_page, [:page_1_A, :page_2_A]

        split_sequence :mastercard_page, [:page_1_B, :page_2_B, :page_3_B]

        split_sequence :paypal_page, []

        # The end points of each split will re-attach to the start of this sequence
        sequence [:review, :complete ]
    end
```
    
This will generate  a series of states (steps) and the navigation between them.

A view partial and associated form, will be expected for each state.

### The Forms

The Controller will search for a related Form for each state using the Factory class/method

```ruby
DatashiftState::FormObjectFactory.form_object_for(journey_plan)
```

The class name for each Form is given by  :

```ruby
"#{mod}::#{journey_plan.state.classify}Form"
```

Where the module can be set in Configuration :

```ruby
Configuration.call.state_module_name
````

So given a module name configuration setting of

```ruby
MyCheckoutEngine::States
```

And a current state of :address - then the Controller will attempt to use Form class

```ruby
MyCheckoutEngine::States::AddressForm
```

When no form is required for a specific HTML page, you an specify that a NullForm is to be used,
either globally for ALL missign forms

```ruby
DatashiftJourney::Configuration.configure do |config|
  config.use_null_form_when_no_form = true
end
```

Or individually by adding the state to the  list of null_form states

```ruby
DatashiftJourney::Configuration.configure do |config|
  config.use_null_form_when_no_form = [:blah, :brexit]
end
```
  
      
The Form must have a factory method, and a constructor that expects a JourneyPlan model instance.

For example

```ruby
    def self.factory(model)
        super(model)
    end
```  
  
Once the Form class has been identified the Controller will attempt to create the new form object
passing in the current journey plan object

           
                   
### The Views

The Controller will expect a view partial, for each related Form.

The partials are rendered passing in the Form as a local variable.

The location of the partial to use for a certain state is given by helper

          def journey_plan_partial_location( state )

The default is `views/journey_plans` but path can be changed using Configuration option `partial_location`

```ruby
   DatashiftJourney::Configuration.configure do |config|
     config.partial_location = "some_more_journey_plans/states"
   end
```

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
