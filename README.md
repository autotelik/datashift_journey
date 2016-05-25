## DataShift State

[![Build Status](https://travis-ci.org/autotelik/datashift_journey.svg?branch=master)](https://travis-ci.org/autotelik/datashift_journey)

Define journeys via simple state based DSL

Take any ActiveRecord model and add a state machine that manages a multi-page forms based journey
such as a questionnaire, survey or registration process.

Collect data as you go via Reform Forms.

Provide high level syntactic sugar to program the journey steps, and manage the views and underlyiong forms (Reform)

The gems we are using :

https://github.com/state-machines/state_machines
https://github.com/state-machines/state_machines-activerecord
https://github.com/apotonick/reform

The app model is decorated with an association to the state machine.

A straightforward description of a Decorator is relatively easy to write in plain old ruby:

“a class that surrounds a given class, adds new capabilities to it, and passes all the unchanged methods to the underlying class”


### Journey Model

The app must inform datashift_journey of the model to host the journey plan and to store data collected on the journey.


This will be the parent model off which all the data to be collected should hang, the concept is 
 like a Registration or Enrollment

For example, in `config/initializers/datashift_journey.rb`

```
DatashiftJourney.journey_plan_class = "Enrollment"
```


### Rendering Views

If you need to set the location of the partials for rendering states, over ride the path via helper
`journey_plan_partial_location` in `app/helpers/application_helper.rb`

```ruby
    def journey_plan_partial_location(state)
      "my_path/states/#{state}"
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
