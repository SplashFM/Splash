require 'spec_helper'

describe Event do
  [
   ['comments', :other, Comment],
   ['mentions', :mentions, Mention],
   ['relationships', :other, Relationship],
   ['splashes', :splashes, Splash],
  ].each { |(label, filter, klass)|
    it "includes #{label}" do
      create!(klass)

      events = Event.scope_by(filter => 1)
      events.should have(1).item
      events.each { |e| e.should be_an_instance_of(klass) }
    end

    it "filters out #{label}" do
      create!(klass)

      Event.scope_by({}).should be_empty
    end
  }
end
