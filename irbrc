require 'irb/completion'

IRB.conf[:PROMPT][:LAMBDA] = {
  AUTO_INDENT: true,
  PROMPT_I: 'λ ',
  PROMPT_S: nil,
  PROMPT_C: nil,
  RETURN: "=> %s\n"
}

IRB.conf[:AUTO_INDENT] = true
IRB.conf[:PROMPT_MODE] = :LAMBDA
IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:USE_READLINE] = true
