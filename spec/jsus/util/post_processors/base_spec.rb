require 'spec_helper'

describe Jsus::Util::PostProcessor::Base do
  it_should_behave_like "Jsus::Util::Mixins::OperatesOnSources"
  subject { described_class.new }
end
