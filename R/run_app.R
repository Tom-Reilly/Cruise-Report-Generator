run_crg_app = function() {
  
  if (interactive()) {
    
    runApp(appDir = system.file("app",
                                package = "crgApp"))
    
  } else {
    
    shinyAppDir(appDir = system.file("app",
                                     package = "crgApp"))
    
  }
  
}

l = run_crg_app()