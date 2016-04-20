## DataShift State

[![Build Status](https://travis-ci.org/autotelik/datashift_state.svg?branch=master)](https://travis-ci.org/autotelik/datashift_state)

Define journeys via simple state based DSL

Collect data as you go


### Journey Model

You need to set which database model will be used to host the journey plan

This will be the parent model off which all the data to be collcted should hang, the concept is 
 like a Registration or Enrollment

For example, in `config/initializers/datashift_state.rb`


```
DatashiftState.journey_plan_class = "Enrollment"
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
