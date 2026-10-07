// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";

Turbo.StreamActions.redirect = function () {
  Turbo.visit(this.target);
};

// Log a welcome message the first time a user lands in the app
try {
  if (!localStorage.getItem("cona_welcomed")) {
    console.log("Welcome to Cona");
    localStorage.setItem("cona_welcomed", "true");
  }
} catch (e) {
  // localStorage may be unavailable (e.g. private mode); skip silently
}
