{
  pkgs,
  palette,
  ...
}: let
  theme = {
    name = "default";
    colors = {
      accent = palette.secondary;
      border = palette.primary;
      borderAccent = palette.cyan;
      borderMuted = palette.dark-gray;
      success = palette.green;
      error = palette.red;
      warning = palette.yellow;
      muted = palette.light-gray;
      dim = palette.dark-gray;
      text = palette.white;
      thinkingText = palette.light-gray;
      selectedBg = palette.light-gray;
      userMessageBg = palette.dark-gray;
      userMessageText = palette.foreground;
      customMessageBg = palette.light-gray;
      customMessageText = palette.foreground;
      customMessageLabel = palette.purple;
      toolPendingBg = palette.light-gray;
      toolSuccessBg = "#2f3a2f"; # No direct match for darker green background
      toolErrorBg = "#3b2f33"; # No direct match for darker red background
      toolTitle = palette.primary;
      toolOutput = palette.foreground;
      mdHeading = palette.primary;
      mdLink = palette.blue;
      mdLinkUrl = palette.dark-gray;
      mdCode = palette.cyan;
      mdCodeBlock = palette.green;
      mdCodeBlockBorder = palette.light-gray;
      mdQuote = palette.dark-gray;
      mdQuoteBorder = palette.light-gray;
      mdHr = palette.light-gray;
      mdListBullet = palette.purple;
      toolDiffAdded = palette.green;
      toolDiffRemoved = palette.red;
      toolDiffContext = palette.light-gray;
      syntaxComment = palette.dark-gray;
      syntaxKeyword = palette.purple;
      syntaxFunction = palette.blue;
      syntaxVariable = palette.red;
      syntaxString = palette.green;
      syntaxNumber = palette.orange;
      syntaxType = palette.yellow;
      syntaxOperator = palette.cyan;
      syntaxPunctuation = palette.foreground;
      thinkingOff = palette.dark-gray;
      thinkingMinimal = palette.light-gray;
      thinkingLow = palette.blue;
      thinkingMedium = palette.cyan;
      thinkingHigh = palette.purple;
      thinkingXhigh = palette.red;
      bashMode = palette.green;
    };
  };
in
  pkgs.writeText "default.json" (builtins.toJSON theme)
