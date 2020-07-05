workflow "Build libvorbis" {
  on = "deployment"
  resolves = ["libvorbisBuildActions"]
}

action "libvorbisBuildActions" {
  uses = "./"
}
