# frozen_string_literal: true

Pry::Prompt.add(:lambda, 'Simple lamdba', ['λ ', '· ']) do |_, _, _, separator|
  separator
end

Pry.config.prompt = Pry::Prompt[:lambda]
