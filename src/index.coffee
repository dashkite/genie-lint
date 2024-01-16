import * as Fn from "@dashkite/joy/function"
import M from "@dashkite/masonry"
import T from "@dashkite/masonry-targets"
import coffee from "@dashkite/masonry-coffee"
import { ESLint } from "eslint"
import chalk from "chalk"

linter = new ESLint
  baseConfig:
    env:
      browser: true
      node: true
    parserOptions:
      sourceType: "module"
      ecmaVersion: "latest"
    rules:
      "no-unused-vars": [
        "warn"
        argsIgnorePattern: "^_"
      ]
      "no-unreachable": "warn"
      "no-unsafe-finally": "warn"
      "no-unsafe-optional-chaining": "warn"
      "use-isnan": "warn"
      "camelcase": [
        "warn"
        allow: [
          "_interop_require_default"
          "_interop_require_wildcard"
          "_export_star"
        ]
      ]
      "complexity": "warn"
      "max-depth": "warn"
      # CS transpiler sometimes takes small functions
      # and makes them large, plus linter misreports 
      # their length ...
      # "max-lines": "warn"
      # "max-statements": "warn"
      # mixins get turned into functions by CS transpiler
      # "max-lines-per-function": "warn"
      "max-params": "warn"
      "new-cap": "warn"
      # TODO unfortunately the CS transpiler makes
      # it difficult for the linter to distinguish between
      # the use an initilization of magic numbers
      # "no-magic-numbers": [
      #   "warn"
      #   ignore: [ -2, -1, 0, 1, 2 ]
      # ]
      "no-useless-catch": "warn"
      "no-useless-call": "warn"
      "no-useless-computed-key": "warn"

defaults =
  targets:
    node: [
      glob: [
        "{src,test}/**/*.coffee"
      ]
    ]
    browser: [
      glob: [
        "{src,test}/**/*.coffee"
      ]
    ]

lint = do ({ warn, error, indent } = {}) ->
  warn = 1
  error = 2
  indent = " ".repeat 2
  newline = "\n"
  ({ source, input }) ->
    results = await linter.lintText input, filePath: source.path
    for { messages } in results
      if messages.length > 0
        console.warn newline, chalk.bold source.path
        for message in messages
          if warn == message.severity
            console.warn indent, chalk.yellow message.message
          else if error = message.severity
            console.error indent, chalk.red message.message

expand = ( targets ) ->
  result = {}
  for target in targets
    result[ target ] = defaults.targets[ target ]
  result

export default ( Genie ) ->
  
  options = { defaults..., ( Genie.get "coffee" )... }

  if Array.isArray options.targets
    options.targets = expand options.targets
  
  Genie.define "lint", M.start [
    T.glob options.targets
    M.read
    M.tr [ coffee, lint ]
  ]
