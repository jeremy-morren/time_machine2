import 'package:universal_io/io.dart' as io;

import 'package:xml/xml.dart' as xml;

import 'package:time_machine2/src/time_machine_internal.dart';
import 'package:time_machine2/src/timezones/cldr/windows_zones.dart';

export 'package:time_machine2/src/timezones/cldr/windows_zones.dart';

// todo: internal
class CldrWindowsZonesParser {
  static WindowsZones parse(xml.XmlDocument document) {
    var mapTimezones = _mapTimezones(document);
    var mapZones = _mapZones(mapTimezones);
    var windowsZonesVersion = _findVersion(document);
    var tzdbVersion = mapTimezones.getAttribute('typeVersion') ?? '';
    var windowsVersion = mapTimezones.getAttribute('otherVersion') ?? '';
    return WindowsZones(
        windowsZonesVersion, tzdbVersion, windowsVersion, mapZones);
  }

  static xml.XmlElement _mapTimezones(xml.XmlDocument document) =>
      document.rootElement
          .findElements('windowsZones')
          .first
          .findElements('mapTimezones')
          .first;

  // todo: internal
  static WindowsZones parseFile(String file) => parse(_loadFile(file));

  static xml.XmlDocument _loadFile(String file) =>
      xml.XmlDocument.parse(io.File(file).readAsStringSync());

  static String _findVersion(xml.XmlDocument document) {
    // String revision = document.Root.Element('version')?.Attribute("number");
    String? revision = document.rootElement
        .findElements('version')
        .firstOrNull
        ?.getAttribute('number');
    // Recent CLDR files contain an unexpanded $Revision$ keyword.
    if (revision == null || revision == r'$Revision$') {
      return '';
    }
    String prefix = r'$Revision: ';
    if (revision.startsWith(prefix)) {
      revision = revision.substring(prefix.length);
    }
    String suffix = r' $';
    if (revision.endsWith(suffix)) {
      revision = revision.substring(0, revision.length - suffix.length);
    }
    return revision;
  }

  /*
  static List<MapZone> _mapZones2(XmlDocument document) =>
      document.Root
          .Element('windowsZones')
          .Element('mapTimezones')
          .Elements('mapZone')
          .Select((x) => new MapZone(x.Attribute('other').Value,
  x.Attribute('territory').Value,
  x.Attribute('type').Value.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries)))
      .ToList();*/

  /// <summary>
  /// Reads the input XML file for the windows mappings.
  /// </summary>
  /// <returns>A lookup of Windows time zone mappings</returns>
  static List<MapZone> _mapZones(xml.XmlElement mapTimezones) => mapTimezones
      .findElements('mapZone')
      .map((x) => MapZone(
          x.getAttribute('other')!,
          x.getAttribute('territory')!,
          x
              .getAttribute('type')!
              .split(RegExp(r'\s+'))
              .where((id) => id.isNotEmpty)
              .toList()))
      .toList();
}
