// Import and register all your controllers

import { application } from "./application"

// Import controllers directly (vanilla Rails approach)
import AutosaveController from "./autosave_controller"

application.register("autosave", AutosaveController)
