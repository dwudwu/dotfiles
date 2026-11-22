# The headless module's settings for this Mac. settings.json is the file the
# headless skill writes and verifies (options listed in the skill's
# references/mac.md, defined in modules/darwin/headless.nix of
# github:kunchenguid/headless). Everything else about the machine stays in
# configuration.nix and home.nix.
{ ... }:
{
  headless = builtins.fromJSON (builtins.readFile ./settings.json);
}
