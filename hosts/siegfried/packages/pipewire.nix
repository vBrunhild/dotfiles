{
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    wireplumber.enable = true;

    alsa = {
      enable = true;
      support32Bit = true;
    };

    wireplumber.extraConfig.bluetoothHeadset = {
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.hfphsp-backend" = "native";
        "bluez5.a2dp.ldac.quality" = "auto";
        "bluez5.roles" = ["a2dp_sink" "a2dp_source" "bap_sink" "bap_source" "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag"];
        "bluez5.codecs" = ["sbc" "sbc_xq" "aac" "ldac" "aptx" "aptx_hd" "aptx_ll" "aptx_ll_duplex" "faststream" "faststream_duplex" "lc3plus_h3" "lc3"];
      };

      "monitor.bluez.rules" = [
        {
          matches = [{"device.name" = "bluez_card.84_AC_60_05_6D_BB";}];
          actions = {
            update-props = {
              "bluez5.a2dp.ldac.quality" = "auto";
              "bluez5.auto-connect" = ["a2dp_sink" "hfp_hf"];
              "device.profile" = "ad2p-sink";
            };
          };
        }
      ];
    };

    wireplumber.extraConfig."51-bluetooth-policy" = {
      "wireplumber.settings" = {
        "bluetooth.autoswitch-to-headset-profile" = false;
      };
    };

    wireplumber.extraConfig."90-disable-internal-mic" = {
      "monitor.alsa.rules" = [
        {
          matches = [{"device.name" = "alsa_card.pci-0000_00_1f.3";}];
          actions = {
            update-props = {
              "device.disabled-ports" = ["analog-input-internal-mic"];
            };
          };
        }
      ];
    };
  };
}
