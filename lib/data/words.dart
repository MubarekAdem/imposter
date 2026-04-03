import 'dart:collection';

enum WordLanguage { english, amharic }

// Public pools used by the game controller.
// Each list is generated to contain exactly 1000 unique entries.
final List<String> kEnglishWordPool = _buildEnglishPool(target: 1000);
final List<String> kAmharicWordPool = _buildAmharicPool(target: 1000);

List<String> _buildEnglishPool({required int target}) {
  final LinkedHashSet<String> pool = LinkedHashSet<String>.from(_englishBaseWords);

  for (final String adjective in _englishAdjectives) {
    for (final String word in _englishBaseWords) {
      pool.add('$adjective $word');
    }
  }

  for (final String word in _englishBaseWords) {
    for (final String place in _englishPlaces) {
      pool.add('$word of $place');
    }
  }

  for (final String adjective in _englishAdjectives) {
    for (final String word in _englishBaseWords) {
      for (final String place in _englishPlaces) {
        pool.add('$adjective $word of $place');
      }
    }
  }

  return _finalizePool(pool: pool, target: target, fallbackBase: _englishBaseWords);
}

List<String> _buildAmharicPool({required int target}) {
  final LinkedHashSet<String> pool = LinkedHashSet<String>.from(_amharicBaseWords);

  for (final String adjective in _amharicAdjectives) {
    for (final String word in _amharicBaseWords) {
      pool.add('$adjective $word');
    }
  }

  for (final String word in _amharicBaseWords) {
    for (final String context in _amharicContexts) {
      pool.add('$word $context');
    }
  }

  for (final String adjective in _amharicAdjectives) {
    for (final String word in _amharicBaseWords) {
      for (final String context in _amharicContexts) {
        pool.add('$adjective $word $context');
      }
    }
  }

  return _finalizePool(pool: pool, target: target, fallbackBase: _amharicBaseWords);
}

List<String> _finalizePool({
  required LinkedHashSet<String> pool,
  required int target,
  required List<String> fallbackBase,
}) {
  int i = 1;
  while (pool.length < target) {
    final String base = fallbackBase[(i - 1) % fallbackBase.length];
    pool.add('$base $i');
    i += 1;
  }

  return pool.take(target).toList(growable: false);
}

const List<String> _englishBaseWords = <String>[
  'Forest',
  'Airport',
  'Castle',
  'Volcano',
  'Pirate',
  'Robot',
  'Cactus',
  'Diamond',
  'Jungle',
  'Library',
  'Comet',
  'Thunder',
  'Bridge',
  'Festival',
  'Compass',
  'Lantern',
  'Bicycle',
  'Planet',
  'Harbor',
  'Desert',
  'River',
  'Mountain',
  'Ocean',
  'Valley',
  'Cloud',
  'Lightning',
  'Storm',
  'Rainbow',
  'Island',
  'Temple',
  'Market',
  'School',
  'Teacher',
  'Doctor',
  'Engineer',
  'Painter',
  'Camera',
  'Phone',
  'Clock',
  'Window',
  'Door',
  'Chair',
  'Table',
  'Bed',
  'Cup',
  'Spoon',
  'Knife',
  'Basket',
  'Bread',
  'Rice',
  'Soup',
  'Chicken',
  'Fish',
  'Egg',
  'Milk',
  'Coffee',
  'Tea',
  'Honey',
  'Sugar',
  'Salt',
  'Pepper',
  'Onion',
  'Garlic',
  'Tomato',
  'Potato',
  'Carrot',
  'Lemon',
  'Orange',
  'Banana',
  'Apple',
  'Mango',
  'Watermelon',
  'Flower',
  'Tree',
  'Grass',
  'Dog',
  'Cat',
  'Horse',
  'Camel',
  'Lion',
  'Tiger',
  'Fox',
  'Elephant',
  'Sheep',
  'Goat',
  'Cow',
  'Bird',
  'Bee',
  'Butterfly',
  'Whale',
  'Boat',
  'Airplane',
  'Train',
  'Bus',
  'Taxi',
  'Motorcycle',
  'Sand',
  'Stone',
  'Gold',
  'Silver',
  'Book',
  'Notebook',
  'Pencil',
  'Map',
  'Key',
  'Bag',
  'Shirt',
  'Dress',
  'Hat',
  'Helmet',
  'Shield',
  'Sword',
  'Arrow',
  'Tower',
  'Village',
  'City',
  'Kingdom',
  'Rocket',
  'Satellite',
  'Galaxy',
  'Meteor',
];

const List<String> _englishAdjectives = <String>[
  'Golden',
  'Silent',
  'Hidden',
  'Ancient',
  'Swift',
  'Frozen',
  'Brave',
  'Lucky',
  'Secret',
  'Emerald',
  'Crimson',
  'Silver',
  'Mighty',
  'Shining',
  'Gentle',
  'Rapid',
  'Wild',
  'Bright',
  'Dark',
  'Royal',
];

const List<String> _englishPlaces = <String>[
  'North',
  'South',
  'East',
  'West',
  'Sky',
  'Sea',
  'Desert',
  'Forest',
  'Mountain',
  'Valley',
  'City',
  'Village',
  'Island',
  'Riverbank',
  'Harbor',
];

const List<String> _amharicBaseWords = <String>[
  'ቤት',
  'መኪና',
  'ጫማ',
  'እሳት',
  'ውሃ',
  'ወንዝ',
  'ተራራ',
  'ሰማይ',
  'ፀሐይ',
  'ጨረቃ',
  'ኮከብ',
  'ዝናብ',
  'ንፋስ',
  'ደመና',
  'በረዶ',
  'መንገድ',
  'ድልድይ',
  'ገበያ',
  'መደብር',
  'ትምህርት ቤት',
  'ዩኒቨርሲቲ',
  'ቤተ መጻሕፍት',
  'ሆስፒታል',
  'መድኃኒት',
  'ዶክተር',
  'መምህር',
  'ተማሪ',
  'ፖሊስ',
  'አስተዳዳሪ',
  'ገበሬ',
  'መሐንዲስ',
  'ኮምፒዩተር',
  'ስልክ',
  'ቴሌቪዥን',
  'ሬዲዮ',
  'ካሜራ',
  'ሰዓት',
  'መብራት',
  'መስኮት',
  'በር',
  'ወንበር',
  'ጠረጴዛ',
  'አልጋ',
  'ማቀዝቀዣ',
  'ኩባያ',
  'ሳህን',
  'ማንኪያ',
  'ቢላ',
  'ቅርጫት',
  'እንጀራ',
  'ዳቦ',
  'ሩዝ',
  'ፓስታ',
  'ሾርባ',
  'ስጋ',
  'ዶሮ',
  'ዓሣ',
  'እንቁላል',
  'ወተት',
  'ቡና',
  'ሻይ',
  'ማር',
  'ስኳር',
  'ጨው',
  'በርበሬ',
  'ሽንኩርት',
  'ነጭ ሽንኩርት',
  'ቲማቲም',
  'ድንች',
  'ካሮት',
  'ጎመን',
  'ሎሚ',
  'ብርቱካን',
  'ሙዝ',
  'ፖም',
  'ማንጎ',
  'ሐብሐብ',
  'አበባ',
  'ዛፍ',
  'ሣር',
  'ውሻ',
  'ድመት',
  'ፈረስ',
  'አህያ',
  'ግመል',
  'አንበሳ',
  'ነብር',
  'ቀበሮ',
  'ዝሆን',
  'ቀንድ አውጣ',
  'በግ',
  'ፍየል',
  'ላም',
  'ዶሮ ጫጩት',
  'ወፍ',
  'ንብ',
  'ቢራቢሮ',
  'ዓሣ ነባሪ',
  'ጀልባ',
  'አውሮፕላን',
  'ባቡር',
  'አውቶቡስ',
  'ታክሲ',
  'ብስክሌት',
  'ሞተር ሳይክል',
  'ጫካ',
  'ባህር',
  'ሐይቅ',
  'ደሴት',
  'ሸለቆ',
  'አሸዋ',
  'ድንጋይ',
  'ወርቅ',
  'ብር',
  'መጽሐፍ',
  'ደብተር',
  'እስክሪብቶ',
  'እርሳስ',
  'ካርታ',
  'ቁልፍ',
  'ቦርሳ',
  'ልብስ',
  'ቀሚስ',
  'ኮፍያ',
];

const List<String> _amharicAdjectives = <String>[
  'ትልቅ',
  'ትንሽ',
  'ፈጣን',
  'ዝግ',
  'ጸጥታ',
  'ድምብ',
  'ብርሃን',
  'ጨለማ',
  'ሙቅ',
  'ቀዝቃዛ',
  'አስደናቂ',
  'አሮጌ',
  'አዲስ',
  'ጠንካራ',
  'ለስላሳ',
  'ውብ',
  'ብልህ',
  'ደስተኛ',
  'ፈራጅ',
  'ጠቃሚ',
];

const List<String> _amharicContexts = <String>[
  'በከተማ',
  'በመንደር',
  'በጫካ',
  'በባህር',
  'በተራራ',
  'በመንገድ',
  'በቤት',
  'በገበያ',
  'በትምህርት ቤት',
  'በማታ',
  'በቀን',
  'በክረምት',
  'በበጋ',
  'በሰሜን',
  'በደቡብ',
];
