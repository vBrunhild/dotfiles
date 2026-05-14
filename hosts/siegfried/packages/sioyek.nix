{pkgs, ...}: {
  environment.systemPackages = [pkgs.sioyek];
  environment.variables.PDFVIEWER = "sioyek";
  xdg.mime.defaultApplications."application/pdf" = ["sioyek.desktop"];
}
