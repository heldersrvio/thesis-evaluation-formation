{ Construct } = require 'constructs'
{ Artifact } = require 'aws-cdk-lib/aws-codepipeline'
{
	GitHubSourceAction
	S3DeployAction
} = require 'aws-cdk-lib/aws-codepipeline-actions'
{ CodeBuildAction } = require 'aws-cdk-lib/aws-codepipeline-actions'
{
	LinuxBuildImage
	PipelineProject
	BuildSpec
} = require 'aws-cdk-lib/aws-codebuild'
codepipeline = require 'aws-cdk-lib/aws-codepipeline'
s3 = require 'aws-cdk-lib/aws-s3'

oauthToken = process.env['GITHUB_OAUTH_TOKEN']
owner = process.env['GITHUB_USER_NAME']
repo = process.env['MAIN_REPOSITORY_NAME']
defaultBranch = process.env['DEFAULT_BRANCH']
testBuildSpec = process.env['TEST_BUILDSPEC']
buildBuildSpec = process.env['BUILD_BUILDSPEC']
buildImage = LinuxBuildImage.STANDARD_5_0

class Main extends Construct
	constructor: (scope, id) ->
		super scope, id
		bucket = new s3.Bucket @, 'Bucket'
		pipeline = new codepipeline.Pipeline @, 'Pipeline'
		sourceArtifact = new Artifact()
		testArtifact = new Artifact()
		sourceStage =
			stageName: 'Source'
			actions: [
				new GitHubSourceAction
					actionName: 'Source-Action'
					oauthToken: oauthToken
					output: sourceArtifact
					owner: owner
					repo: repo
					branch: defaultBranch
			]
		testStage =
			stageName: 'Test'
			actions: [
				new CodeBuildAction
					actionName: 'Test-Action'
					input: sourceArtifact
					buildSpec: BuildSpec.fromSourceFilename testBuildSpec
					project: new PipelineProject @, 'TestProject',
						environment: buildImage: buildImage
					outputs: [testArtifact]
			]
		deployStage =
			stageName: 'Deploy'
			actions: [
				new S3DeployAction
					actionName: 'Deploy-Action'
					bucket: bucket
					input: testArtifact
			]
		pipeline.addStage sourceStage
		pipeline.addStage testStage
		pipeline.addStage deployStage

module.exports = { Main }
