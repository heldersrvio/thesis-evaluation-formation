{ Construct } = require 'constructs'
{ Artifact } = require 'aws-cdk-lib/aws-codepipeline'
{
	GitHubSourceAction
	S3DeployAction
} = require 'aws-cdk-lib/aws-codepipeline-actions'
{ CodeBuildAction } = require 'aws-cdk-lib/aws-codepipeline-actions'
{ LinuxBuildImage, PipelineProject } = require 'aws-cdk-lib/aws-codebuild'
codepipeline = require 'aws-cdk-lib/aws-codepipeline'
s3 = require 'aws-cdk-lib/aws-s3'

oauthToken = 'TOKEN'
owner = 'owner'
repo = 'kMeans-labeling-discretization'
defaultBranch = 'master'
buildImage = LinuxBuildImage.STANDARD_5_0

class Main extends Construct
	constructor: (scope, id) ->
		super scope, id
		bucket = new s3.Bucket @, 'Bucket'
		pipeline = new codepipeline.Pipeline @, 'Pipeline'
		sourceArtifact = new Artifact()
		testArtifact = new Artifact()
		buildArtifact = new Artifact()
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
					project: new PipelineProject @, 'TestProject',
						environment: buildImage: buildImage
					outputs: [testArtifact]
			]
		buildStage =
			stageName: 'Build'
			actions: [
				new CodeBuildAction
					actionName: 'Build-Action'
					input: testArtifact
					project: new PipelineProject @, 'BuildProject',
						environment: buildImage: buildImage
					outputs: [buildArtifact]
			]
		deployStage =
			stageName: 'Deploy'
			actions: [
				new S3DeployAction
					actionName: 'Deploy-Action'
					bucket: bucket
					input: buildArtifact
			]
		pipeline.addStage sourceStage
		pipeline.addStage testStage
		pipeline.addStage buildStage
		pipeline.addStage deployStage

module.exports = { Main }
