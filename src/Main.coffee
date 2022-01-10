{ Construct } = require('constructs')
{ Artifact } = require('aws-cdk-lib/aws-codepipeline')
{ GitHubSourceAction } = require('aws-cdk-lib/aws-codepipeline-actions')
{ CodeBuildAction } = require('aws-cdk-lib/aws-codepipeline-actions')
{ LinuxBuildImage, PipelineProject } = require('aws-cdk-lib/aws-codebuild')
codepipeline = require('aws-cdk-lib/aws-codepipeline')

class Main extends Construct
    constructor : (scope, id) ->
        super(scope, id)
        pipeline = new codepipeline.Pipeline @, 'Pipeline'
        artifact = new Artifact()
        sourceStage =
            stageName: 'Source'
            actions: [
                new GitHubSourceAction
                    actionName: 'Source-Action'
                    oauthToken: 'TOKEN'
                    output: artifact
                    owner: 'owner'
                    repo: 'kMeans-labeling-discretization'
            ]
        buildStage =
            stageName: 'Build'
            actions: [
                new CodeBuildAction
                    actionName: 'Build-Action'
                    input: artifact
                    project:
                        new PipelineProject @, 'BuildProject', { environment: { buildImage: LinuxBuildImage.STANDARD_5_0 } }
                    outputs: [ new Artifact() ]
            ]
        pipeline.addStage sourceStage
        pipeline.addStage buildStage
        # pipeline = new codepipeline.Pipeline @, 'Pipeline', { stages: [ buildStage, sourceStage ] }

module.exports = { Main }