#!/usr/bin/env node

cdk = require 'aws-cdk-lib'
{
	ThesisEvaluationFormationStack
} = require '../lib/ThesisEvaluationFormationStack'

app = new cdk.App()
new ThesisEvaluationFormationStack app, 'ThesisEvaluationFormationStack',
	env:
		account: process.env.CDK_DEFAULT_ACCOUNT
		region: process.env.CDK_DEFAULT_REGION
