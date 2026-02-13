// React component registry — maps component names to their implementations
// Add new components here as they are created

import TestConnectionButton from "./TestConnectionButton"
import ChannelAudienceToggler from "./ChannelAudienceToggler"
import AiImproveButton from "./AiImproveButton"
import AiLoadingOverlay from "./AiLoadingOverlay"
import RoleSelector from "./RoleSelector"
import AudienceTypeToggle from "./AudienceTypeToggle"
import AudienceScopeToggle from "./AudienceScopeToggle"

const componentRegistry = {
  TestConnectionButton,
  ChannelAudienceToggler,
  AiImproveButton,
  AiLoadingOverlay,
  RoleSelector,
  AudienceTypeToggle,
  AudienceScopeToggle,
}

export default componentRegistry
