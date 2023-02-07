import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import * as route53 from "aws-cdk-lib/aws-route53";
import * as acm from "aws-cdk-lib/aws-certificatemanager";
import * as ec2 from "aws-cdk-lib/aws-ec2";
import * as ecs from "aws-cdk-lib/aws-ecs";
import * as ecsPatterns from "aws-cdk-lib/aws-ecs-patterns";
import { SslPolicy } from "aws-cdk-lib/aws-elasticloadbalancingv2";
import { IpAddresses } from "aws-cdk-lib/aws-ec2";

// import * as sqs from 'aws-cdk-lib/aws-sqs';

const domain = "enact-it.training";

const instances = [
  "alpha",
  "beta",
  "charlie",
  "delta",
  "echo",
  "foxtrot",
  "gamma",
  "hotel",
];

export class JuiceshopAndWrongsecretsStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const vpc = new ec2.Vpc(this, "VPC", {
      ipAddresses: IpAddresses.cidr("10.10.0.0/16"),
    });

    const cluster = new ecs.Cluster(this, "EcsCluster", {
      clusterName: "wrongsecrets-and-juiceshop",
      vpc: vpc,
      enableFargateCapacityProviders: true,
    });

    const domainZone = route53.HostedZone.fromLookup(this, "Zone", {
      domainName: domain,
    });
    const certificate = new acm.Certificate(this, "Cert", {
      domainName: domain,
      certificateName: domain,
      subjectAlternativeNames: ["enact-it.training", "*.enact-it.training"],
      validation: acm.CertificateValidation.fromDns(domainZone),
    });

    // Create separate instances for all JuiceShop folks
    instances.forEach((element) => {
      new ecsPatterns.ApplicationLoadBalancedFargateService(
        this,
        "JuiceShop" + element,
        {
          // vpc,
          cluster,
          certificate,
          sslPolicy: SslPolicy.RECOMMENDED,
          domainName: "juiceshop-" + element + "." + domain,
          domainZone,
          redirectHTTP: true,
          cpu: 512,
          memoryLimitMiB: 1024,
          taskImageOptions: {
            image: ecs.ContainerImage.fromRegistry(
              "bkimminich/juice-shop:latest"
            ),
            containerPort: 3000,
          },
        }
      );
    });

    const wrongsecrets = new ecsPatterns.ApplicationLoadBalancedFargateService(
      this,
      "WrongSecrets",
      {
        // vpc,
        cluster,
        certificate,
        sslPolicy: SslPolicy.RECOMMENDED,
        domainName: "wrongsecrets" + "." + domain,
        domainZone,
        redirectHTTP: true,
        cpu: 512,
        memoryLimitMiB: 1024,
        taskImageOptions: {
          image: ecs.ContainerImage.fromRegistry(
            "jeroenwillemsen/wrongsecrets:latest-no-vault"
          ),
          containerPort: 8080,
        },
      }
    );
  }
}
