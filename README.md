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
    
## Setup and Configuration - Initializer

Use the install generators to set up Datashift Journey:

We need an existing parent model against which which all the data to be collected hangs,
the concept is like a  Checkout, Registration or Enrollment. 

For example, as you progress through the checkout one step might be to collect an address,
so we would expect the Checkout model to have an association to an address.

We can inform `datashift_journey` of this model class, via this initializer.

For example, to use a model called `Checkout`

```ruby
rails generate datashift_journey:initializer --model Checkout
```

Creates the file `config/initializers/datashift_journey.rb`

This model will be auto-decorated with an association to a state machine.

This model be an existing model, or created from scratch, but it's **vital** that your journey class
 has a string column called `state`
 
If the model does not yet exist the initializer will create a basic migration for you containing this
 
If you need to add an associated migration yourself it should contain `t.string :state` e.g 

```ruby
rails generate "migration", "AddStateToMyModel", "state:string"
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

A stubbed out journey definition is added by the initializer to a concern of the supplied model.

You will need to edit the jounrey and set the initial: step.

Here's a simple example for a basic checkout, on an ActiveRecord model, `Checkout`

```ruby
  MachineBuilder.extend_journey_plan_class(initial: :ship_address) do

    sequence [:ship_address, :bill_address]

    split_on_equality( :payment,
                       "payment_card",    # Helper method on Checkout that returns card type from Payment
                       visa_page: 'visa',
                       mastercard_page: 'mastercard',
                       paypal_page: 'paypal'
    )

    split_sequence :visa_page, [:page_1_A, :page_2_A]

    split_sequence :mastercard_page, [:page_1_B, :page_2_B, :page_3_B]

    split_sequence :paypal_page, []

    sequence [:review, :complete ]
  end
```
    
The state machine will generate a series of states (steps) starting at :ship_address and finishing at :complete,
and also forward and backwards navigation between them.

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

Configuration can be set in an initializer using a standard block format.

So to set the *module* structure, use 

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

The default is `app/views` but path can be changed using Configuration option `partial_location`

This will be required in the path format, if you are using multiple namespaces/folders

```ruby
   DatashiftJourney::Configuration.configure do |config|
     config.partial_location = "checkout_engine"
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
