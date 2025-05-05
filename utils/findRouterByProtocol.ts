import { Routers } from "../constants";

export const findRouterByProtocol = (protocol: number) => {
  const routerKeys = Object.keys(Routers);
  const key = routerKeys.at(protocol);
  return key ? Routers[key] : undefined;
};
