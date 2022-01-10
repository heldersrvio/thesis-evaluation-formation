Main = require '../lib/Main'
{ Stack, Duration } = require 'aws-cdk-lib'

class ThesisEvaluationFormationStack extends Stack
	# @param {Construct} scope
	# @param {string} id
	# @param {StackProps=} props

	constructor: (scope, id, props) ->
		super scope, id, props
		thesisEvaluationService = new Main.Main this, 'ThesisEvaluation'

module.exports = { ThesisEvaluationFormationStack }
