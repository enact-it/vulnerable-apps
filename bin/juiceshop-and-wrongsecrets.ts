#!/usr/bin/env node
import "source-map-support/register";
import * as cdk from "aws-cdk-lib";
import { JuiceshopAndWrongsecretsStack } from "../lib/juiceshop-and-wrongsecrets-stack";

const app = new cdk.App();
new JuiceshopAndWrongsecretsStack(app, "JuiceshopAndWrongsecretsStack", {
  env: { account: "623040704282", region: "eu-west-1" },
});
