RSpec::Matchers.define :be_fresh do |env, old_asset|
  match do |actual|
    if actual.respond_to?(:fresh?)
      if actual.method(:fresh?).arity == 1
        actual.fresh?(env)
      else
        actual.fresh?
      end
    else
      actual.eql?(old_asset)
    end
  end

  failure_message do |env|
    'expected asset to be fresh'
  end

  failure_message_when_negated do |env|
    'expected asset to be stale'
  end
end
