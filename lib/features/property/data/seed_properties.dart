import '../../lifestyle/domain/entities/lifestyle_profile.dart';
import '../domain/entities/property.dart';
import 'models/property_model.dart';

const _img = 'https://images.unsplash.com';

/// Kigali listings matching the Figma design. Used to seed Firestore on
/// first run and as the demo-mode dataset.
const kSeedProperties = [
  PropertyModel(
    id: 'ayana',
    name: 'Ayana',
    address: '5 Vision Heights, Kimihurura, Kigali, Rwanda',
    description:
        'Bright shared house five minutes from the ALU shuttle stop. Two '
        'rooms available with a study-friendly living room, fibre internet '
        'and a housemate group that keeps quiet hours during exams.',
    pricePerMonth: 120,
    rating: 4.6,
    compatibility: 87,
    images: [
      '$_img/photo-1600596542815-ffad4c1539a9?w=800&q=60',
      '$_img/photo-1600607687939-ce8a6c25118c?w=800&q=60',
      '$_img/photo-1554995207-c18c203602cb?w=800&q=60',
      '$_img/photo-1493809842364-78817add7ffb?w=800&q=60',
    ],
    bedrooms: 3,
    bathrooms: 2,
    agentName: 'Aline Uwase',
    agentPhone: '+250 788 000 111',
    hostType: HostType.student,
    listingKind: ListingKind.housemate,
    hostLifestyle: LifestyleProfile(
      bedtime: Bedtime.tenToMidnight,
      cleanliness: Cleanliness.tidy,
      social: SocialStyle.occasional,
      study: StudyStyle.silentRoom,
      guests: GuestFrequency.rarely,
      smoking: SmokingStance.nonSmokerPrefersNone,
      budget: BudgetBand.from100To150,
      gender: Gender.woman,
      genderPreference: GenderPreference.noPreference,
      sharing: SharingStyle.shareBasics,
      pets: PetStance.fineWithThem,
      bio:
          'Third-year software engineering student. Early to bed, cooks '
          'most evenings, and keeps the kitchen spotless.',
    ),
  ),
  PropertyModel(
    id: 'sekimondo',
    name: 'Sekimondo Apartments',
    address: '71 Akagera Road, Nyamirambo, Kigali, Rwanda',
    description:
        'Sunny apartment with a blue veranda and space for four students. '
        'Walking distance to buses, markets and a co-working cafe. Landlord '
        'is verified and offers flexible sublet windows during breaks.',
    pricePerMonth: 210,
    rating: 4.8,
    compatibility: 76,
    images: [
      '$_img/photo-1600585154340-be6161a56a0c?w=800&q=60',
      '$_img/photo-1560448204-e02f11c3d0e2?w=800&q=60',
      '$_img/photo-1502672260266-1c1ef2d93688?w=800&q=60',
      '$_img/photo-1522708323590-d24dbb6b0267?w=800&q=60',
    ],
    bedrooms: 4,
    bathrooms: 2,
    agentName: 'Eric Mugisha',
    agentPhone: '+250 788 000 222',
    hostType: HostType.student,
    listingKind: ListingKind.housemate,
    hostLifestyle: LifestyleProfile(
      bedtime: Bedtime.afterTwo,
      cleanliness: Cleanliness.cleanWhenNeeded,
      social: SocialStyle.verySocial,
      study: StudyStyle.campusOrLibrary,
      guests: GuestFrequency.often,
      smoking: SmokingStance.nonSmokerTolerant,
      budget: BudgetBand.from150To250,
      gender: Gender.man,
      genderPreference: GenderPreference.noPreference,
      sharing: SharingStyle.shareEverything,
      pets: PetStance.loveThem,
      bio:
          'Final-year business student. I DJ on weekends, so the house is '
          'rarely quiet on a Friday night.',
    ),
  ),
  PropertyModel(
    id: 'ben',
    name: 'Ben',
    address: '71 Akagera Road, Nyamirambo, Kigali, Rwanda',
    description:
        'Modern duplex room in a calm compound. Ideal for a final-year '
        'student who wants space to focus, with a shared kitchen and a '
        'housemate crew that cooks together on weekends.',
    pricePerMonth: 180,
    rating: 4.4,
    compatibility: 69,
    images: [
      '$_img/photo-1568605114967-8130f3a36994?w=800&q=60',
      '$_img/photo-1493809842364-78817add7ffb?w=800&q=60',
      '$_img/photo-1554995207-c18c203602cb?w=800&q=60',
    ],
    bedrooms: 2,
    bathrooms: 1,
    agentName: 'Ben Habimana',
    agentPhone: '+250 788 000 333',
    hostType: HostType.realtor,
    listingKind: ListingKind.entirePlace,
  ),
  PropertyModel(
    id: 'bosko',
    name: 'Bosko Apartments',
    address: '12 KG 549 St, Kacyiru, Kigali, Rwanda',
    description:
        'High-rise student apartments next to the innovation city offices. '
        'Rooms come furnished with a desk and wardrobe; water and security '
        'are included in the rent.',
    pricePerMonth: 120,
    rating: 4.5,
    compatibility: 92,
    images: [
      '$_img/photo-1522708323590-d24dbb6b0267?w=800&q=60',
      '$_img/photo-1502672260266-1c1ef2d93688?w=800&q=60',
      '$_img/photo-1560448204-e02f11c3d0e2?w=800&q=60',
    ],
    bedrooms: 1,
    bathrooms: 1,
    agentName: 'Josiane Ingabire',
    agentPhone: '+250 788 000 444',
    hostType: HostType.student,
    listingKind: ListingKind.housemate,
    hostLifestyle: LifestyleProfile(
      bedtime: Bedtime.beforeTen,
      cleanliness: Cleanliness.spotless,
      social: SocialStyle.homebody,
      study: StudyStyle.silentRoom,
      guests: GuestFrequency.never,
      smoking: SmokingStance.nonSmokerPrefersNone,
      budget: BudgetBand.from100To150,
      gender: Gender.woman,
      genderPreference: GenderPreference.sameGenderOnly,
      sharing: SharingStyle.keepSeparate,
      pets: PetStance.allergic,
      bio:
          'Medical student on early rotations. Quiet hours from 9pm, and I '
          'keep the shared spaces spotless.',
    ),
  ),
  PropertyModel(
    id: 'manhari',
    name: 'Manhari',
    address: '3 Lake View Close, Nyarutarama, Kigali, Rwanda',
    description:
        'Poolside residence sharing with three international students. '
        'Short-term sublets welcome during internship season; the host is a '
        'former ALU student who understands the academic calendar.',
    pricePerMonth: 230,
    rating: 4.7,
    compatibility: 84,
    images: [
      '$_img/photo-1512917774080-9991f1c4c750?w=800&q=60',
      '$_img/photo-1600596542815-ffad4c1539a9?w=800&q=60',
      '$_img/photo-1600607687939-ce8a6c25118c?w=800&q=60',
    ],
    bedrooms: 4,
    bathrooms: 3,
    agentName: 'Nadia Keza',
    agentPhone: '+250 788 000 555',
    hostType: HostType.student,
    listingKind: ListingKind.housemate,
    hostLifestyle: LifestyleProfile(
      bedtime: Bedtime.midnightToTwo,
      cleanliness: Cleanliness.tidy,
      social: SocialStyle.mostWeekends,
      study: StudyStyle.musicInRoom,
      guests: GuestFrequency.sometimes,
      smoking: SmokingStance.nonSmokerTolerant,
      budget: BudgetBand.from150To250,
      gender: Gender.man,
      genderPreference: GenderPreference.noPreference,
      sharing: SharingStyle.shareBasics,
      pets: PetStance.fineWithThem,
      bio:
          'Second-year economics. Out most Saturdays, in the library most '
          'Sundays.',
    ),
  ),
  PropertyModel(
    id: 'mavoona',
    name: 'Mavoona Apartments',
    address: '88 Inyange Street, Remera, Kigali, Rwanda',
    description:
        'City-view apartment block popular with University of Rwanda '
        'students. Verified listing with structured pricing: rent, deposit '
        'and utilities are all published up front.',
    pricePerMonth: 320,
    rating: 4.8,
    compatibility: 71,
    images: [
      '$_img/photo-1570129477492-45c003edd2be?w=800&q=60',
      '$_img/photo-1522708323590-d24dbb6b0267?w=800&q=60',
      '$_img/photo-1560448204-e02f11c3d0e2?w=800&q=60',
    ],
    bedrooms: 2,
    bathrooms: 1,
    agentName: 'Patrick Ndoli',
    agentPhone: '+250 788 000 666',
    hostType: HostType.realtor,
    listingKind: ListingKind.entirePlace,
  ),
  PropertyModel(
    id: 'takitea',
    name: 'Takitea Homestay',
    address: '5 Vision Heights, Kimihurura, Kigali, Rwanda',
    description:
        'Family-run homestay with private student rooms and meals on '
        'request. A soft landing for first-year internationals arriving in '
        'Kigali without local connections.',
    pricePerMonth: 150,
    rating: 4.9,
    compatibility: 81,
    images: [
      '$_img/photo-1600585154340-be6161a56a0c?w=800&q=60',
      '$_img/photo-1554995207-c18c203602cb?w=800&q=60',
      '$_img/photo-1493809842364-78817add7ffb?w=800&q=60',
    ],
    bedrooms: 3,
    bathrooms: 2,
    agentName: 'Mama Takitea',
    agentPhone: '+250 788 000 777',
    hostType: HostType.student,
    listingKind: ListingKind.housemate,
    hostLifestyle: LifestyleProfile(
      bedtime: Bedtime.tenToMidnight,
      cleanliness: Cleanliness.cleanWhenNeeded,
      social: SocialStyle.mostWeekends,
      study: StudyStyle.anywhere,
      guests: GuestFrequency.sometimes,
      smoking: SmokingStance.nonSmokerTolerant,
      budget: BudgetBand.from150To250,
      gender: Gender.woman,
      genderPreference: GenderPreference.noPreference,
      sharing: SharingStyle.shareEverything,
      pets: PetStance.loveThem,
      bio:
          'Design student, always a project on the table. Friendly house '
          'with shared meals on Sundays.',
    ),
  ),
  PropertyModel(
    id: 'simba',
    name: 'Simba Apartments',
    address: '14 Umucyo Lane, Kacyiru, Kigali, Rwanda',
    description:
        'Quiet apartments a short moto ride from campus. One-month minimum '
        'stay makes it a favourite for exchange students and internship '
        'sublets.',
    pricePerMonth: 200,
    rating: 4.8,
    compatibility: 78,
    images: [
      '$_img/photo-1570129477492-45c003edd2be?w=800&q=60',
      '$_img/photo-1502672260266-1c1ef2d93688?w=800&q=60',
      '$_img/photo-1600607687939-ce8a6c25118c?w=800&q=60',
    ],
    bedrooms: 2,
    bathrooms: 1,
    agentName: 'Divine Umutoni',
    agentPhone: '+250 788 000 888',
    hostType: HostType.student,
    listingKind: ListingKind.housemate,
    hostLifestyle: LifestyleProfile(
      bedtime: Bedtime.midnightToTwo,
      cleanliness: Cleanliness.tidy,
      social: SocialStyle.occasional,
      study: StudyStyle.silentRoom,
      guests: GuestFrequency.rarely,
      smoking: SmokingStance.nonSmokerPrefersNone,
      budget: BudgetBand.from150To250,
      gender: Gender.man,
      genderPreference: GenderPreference.noPreference,
      sharing: SharingStyle.shareBasics,
      pets: PetStance.preferNone,
      bio:
          'Engineering finalist. Long study nights, a quiet house, and the '
          'occasional football match on the TV.',
    ),
  ),
  PropertyModel(
    id: 'kigali-heights',
    name: 'Kigali Heights Residence',
    address: 'KG 7 Ave, Kimironko, Kigali, Rwanda',
    description:
        'Shared residence near Kimironko market with fast bus links to all '
        'three campuses. Great for students who want lively housemates and '
        'weekend plans.',
    pricePerMonth: 140,
    rating: 4.3,
    compatibility: 74,
    images: [
      '$_img/photo-1568605114967-8130f3a36994?w=800&q=60',
      '$_img/photo-1600596542815-ffad4c1539a9?w=800&q=60',
      '$_img/photo-1522708323590-d24dbb6b0267?w=800&q=60',
    ],
    bedrooms: 5,
    bathrooms: 3,
    agentName: 'Samuel Iradukunda',
    agentPhone: '+250 788 000 999',
    hostType: HostType.realtor,
    listingKind: ListingKind.entirePlace,
  ),
];
