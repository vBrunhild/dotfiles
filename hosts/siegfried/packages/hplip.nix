{
  hplip,
  python312Packages,
}:
hplip.override {
  python3Packages = python312Packages;
  withPlugin = true;
}
