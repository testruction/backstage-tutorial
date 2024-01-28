import { CatalogBuilder } from '@backstage/plugin-catalog-backend';
import { ScaffolderEntitiesProcessor } from '@backstage/plugin-scaffolder-backend';
import { Router } from 'express';
import { PluginEnvironment } from '../types';
import { GithubEntityProvider } from '@backstage/plugin-catalog-backend-module-github';
import { LinguistTagsProcessor } from '@backstage/plugin-linguist-backend';

export default async function createPlugin(
  env: PluginEnvironment,
): Promise<Router> {
  const builder = await CatalogBuilder.create(env);
  builder.addEntityProvider(
    GithubEntityProvider.fromConfig(env.config, {
      logger: env.logger,
      scheduler: env.scheduler,
    }),
  );
  builder.addProcessor(new ScaffolderEntitiesProcessor());
  builder.addProcessor(
    LinguistTagsProcessor.fromConfig(env.config, {
      logger: env.logger,
      discovery: env.discovery,
    })
  );
  const { processingEngine, router } = await builder.build();
  await processingEngine.start();
  return router;
}
