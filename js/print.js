// Ensures all details are opened before printing.
window.addEventListener("beforeprint", function() {
  let details = document.querySelectorAll("details");
  for(const detail of details){
    detail.setAttribute("open", "");
  }
});
