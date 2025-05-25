import { Routers } from "../constants";

/**
 * Finds a router by its protocol number from the available routers.
 * @param protocol The protocol number to look up
 * @returns The router corresponding to the protocol number, or undefined if not found
 */
export const findRouterByProtocol = (protocol: number) => {
  const routerKeys = Object.keys(Routers);
  const key = routerKeys.at(protocol);
  return key ? Routers[key] : undefined;
};
