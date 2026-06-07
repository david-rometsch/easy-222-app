import 'package:http/http.dart';










// hardcoded version 
final wcaData = {
  "person": {
    "name": "David Rometsch",
    "gender": "m",
    "url": "https://www.worldcubeassociation.org/persons/2019ROME03",
    "country": {
      "id": "Switzerland",
      "name": "Switzerland",
      "continent_id": "_Europe",
      "iso2": "CH",
    },
    "delegate_status": null,
    "class": "person",
    "teams": [],
    "avatar": {
      "id": null,
      "status": "approved",
      "thumbnail_crop_x": 0,
      "thumbnail_crop_y": 0,
      "thumbnail_crop_w": 100,
      "thumbnail_crop_h": 100,
      "url":
          "https://assets.worldcubeassociation.org/assets/12e66ac/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png",
      "thumb_url":
          "https://assets.worldcubeassociation.org/assets/12e66ac/assets/missing_avatar_thumb-d77f478a307a91a9d4a083ad197012a391d5410f6dd26cb0b0e3118a5de71438.png",
      "is_default": true,
      "can_edit_thumbnail": false,
    },
    "wca_id": "2019ROME03",
    "country_iso2": "CH",
    "id": "2019ROME03",
  },
  "competition_count": 16,
  "personal_records": {
    "222": {
      "single": {
        "id": 41104,
        "person_id": "2019ROME03",
        "event_id": "222",
        "best": 368,
        "world_rank": 40860,
        "continent_rank": 12418,
        "country_rank": 247,
      },
      "average": {
        "id": 46667,
        "person_id": "2019ROME03",
        "event_id": "222",
        "best": 586,
        "world_rank": 46507,
        "continent_rank": 13281,
        "country_rank": 259,
      },
    },
    "333": {
      "single": {
        "id": 239636,
        "person_id": "2019ROME03",
        "event_id": "333",
        "best": 1387,
        "world_rank": 56582,
        "continent_rank": 13855,
        "country_rank": 253,
      },
      "average": {
        "id": 227850,
        "person_id": "2019ROME03",
        "event_id": "333",
        "best": 1591,
        "world_rank": 49742,
        "continent_rank": 12062,
        "country_rank": 212,
      },
    },
    "333fm": {
      "single": {
        "id": 479082,
        "person_id": "2019ROME03",
        "event_id": "333fm",
        "best": 40,
        "world_rank": 5777,
        "continent_rank": 2212,
        "country_rank": 59,
      },
    },
    "333oh": {
      "single": {
        "id": 541023,
        "person_id": "2019ROME03",
        "event_id": "333oh",
        "best": 4121,
        "world_rank": 48179,
        "continent_rank": 12605,
        "country_rank": 233,
      },
    },
    "444": {
      "single": {
        "id": 594074,
        "person_id": "2019ROME03",
        "event_id": "444",
        "best": 5930,
        "world_rank": 29224,
        "continent_rank": 8134,
        "country_rank": 153,
      },
      "average": {
        "id": 545451,
        "person_id": "2019ROME03",
        "event_id": "444",
        "best": 6462,
        "world_rank": 26361,
        "continent_rank": 7309,
        "country_rank": 138,
      },
    },
    "555": {
      "single": {
        "id": 682234,
        "person_id": "2019ROME03",
        "event_id": "555",
        "best": 19511,
        "world_rank": 33019,
        "continent_rank": 10402,
        "country_rank": 215,
      },
    },
    "pyram": {
      "single": {
        "id": 857493,
        "person_id": "2019ROME03",
        "event_id": "pyram",
        "best": 973,
        "world_rank": 64482,
        "continent_rank": 19955,
        "country_rank": 366,
      },
      "average": {
        "id": 772545,
        "person_id": "2019ROME03",
        "event_id": "pyram",
        "best": 2044,
        "world_rank": 100189,
        "continent_rank": 29702,
        "country_rank": 542,
      },
    },
  },
  "medals": {"gold": 0, "silver": 0, "bronze": 0, "total": 0},
  "records": {"national": 0, "continental": 0, "world": 0, "total": 0},
  "total_solves": 259,
} as Map<String, dynamic>;
