import React from "react"
import { createRoot } from "react-dom/client"
import componentRegistry from "./components/index"

function mountComponents() {
  const nodes = document.querySelectorAll("[data-react-component]")

  nodes.forEach((node) => {
    // Skip already-mounted nodes
    if (node.dataset.reactMounted) return

    const name = node.dataset.reactComponent
    const Component = componentRegistry[name]

    if (!Component) {
      console.warn(`React component "${name}" not found in registry`)
      return
    }

    const props = node.dataset.reactProps
      ? JSON.parse(node.dataset.reactProps)
      : {}

    const root = createRoot(node)
    root.render(React.createElement(Component, props))
    node.dataset.reactMounted = "true"

    // Store root reference for cleanup
    node._reactRoot = root
  })
}

function unmountComponents() {
  const nodes = document.querySelectorAll("[data-react-mounted]")
  nodes.forEach((node) => {
    if (node._reactRoot) {
      node._reactRoot.unmount()
      delete node._reactRoot
      delete node.dataset.reactMounted
    }
  })
}

// Mount on initial page load
document.addEventListener("DOMContentLoaded", mountComponents)

// Mount after Turbo navigations
document.addEventListener("turbo:load", mountComponents)

// Cleanup before Turbo navigates away
document.addEventListener("turbo:before-render", unmountComponents)
