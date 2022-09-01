self: super: {
  # https://github.com/nmattia/niv/issues/332#issuecomment-958449218
  niv =
    self.haskell.lib.compose.overrideCabal
      (drv: { enableSeparateBinOutput = false; })
      super.haskellPackages.niv;
}