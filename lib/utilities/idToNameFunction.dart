import 'package:xturbox/data_providers/models/savedData.dart';

class IdToName {
  static idToName(String type, String id) {
    switch (type) {
      case 'city':
        try {
          for (int i = 0; i < SavedData.resourcesData.city!.length; i++) {
            if (id == SavedData.resourcesData.city![i].id.toString()) {
              return SavedData.resourcesData.city![i].name.toString();
            }
          }
        } catch (e) {
          return '';
        }
        break;

      case 'ticketCategory':
        try {
          for (int i = 0; i < SavedData.resourcesData.ticketCategory!.length; i++) {
            if (id == SavedData.resourcesData.ticketCategory![i].id.toString()) {
              return SavedData.resourcesData.ticketCategory![i].name.toString();
            }
          }
        } catch (e) {
          return '';
        }
        break;

      // case 'permission':
      //   try {
      //     for (int i = 0; i < SavedData.resourcesData.permission!.length; i++) {
      //       if (id == SavedData.resourcesData.permission![i].id.toString()) {
      //         return SavedData.resourcesData.permission![i].name.toString();
      //       }
      //     }
      //   } catch (e) {
      //     return '';
      //   }
      //   break;

      case 'ticketStatus':
        try {
          for (int i = 0; i < SavedData.resourcesData.ticketStatus!.length; i++) {
            if (id == SavedData.resourcesData.ticketStatus![i].id.toString()) {
              return SavedData.resourcesData.ticketStatus![i].name.toString();
            }
          }
        } catch (e) {
          return '';
        }
        break;

      // case 'shipmentStatus':
      //   try {
      //     for (int i = 0;
      //         i < SavedData.resourcesData.shipmentStatus!.length;
      //         i++) {
      //       if (id ==
      //           SavedData.resourcesData.shipmentStatus![i].id.toString()) {
      //         return SavedData.resourcesData.shipmentStatus![i].name.toString();
      //       }
      //     }
      //   } catch (e) {
      //     return '';
      //   }
      //   break;

      case 'paymentType':
        try {
          for (int i = 0;
              i < SavedData.resourcesData.paymentType!.length;
              i++) {
            if (id == SavedData.resourcesData.paymentType![i].id.toString()) {
              return SavedData.resourcesData.paymentType![i].name.toString();
            }
          }
        } catch (e) {
          return '';
        }
        break;

      case 'cancellation':
        try {
          for (int i = 0;
              i < SavedData.resourcesData.cancellation!.length;
              i++) {
            if (id == SavedData.resourcesData.cancellation![i].id.toString()) {
              return SavedData.resourcesData.cancellation![i].name.toString();
            }
          }
        } catch (e) {
          return '';
        }
        break;
      case 'payment_method':
        try {
          for (int i = 0; i < (SavedData.resourcesData.payment_method?.length ?? 0); i++) {
            if (id == SavedData.resourcesData.payment_method![i].id.toString()) {
              return SavedData.resourcesData.payment_method![i].name.toString();
            }
          }
        } catch (e) {
          return '';
        }
        break;

      // case 'times':
      //   try {
      //     for (int i = 0; i < SavedData.resourcesData.times!.length; i++) {
      //       if (id == SavedData.resourcesData.times![i].id.toString()) {
      //         return SavedData.resourcesData.times![i].name.toString();
      //       }
      //     }
      //   } catch (e) {
      //     return '';
      //   }
      //   break;

      // case 'idTypes':
      //   try {
      //     for (int i = 0; i < SavedData.resourcesData.idTypes!.length; i++) {
      //       if (id == SavedData.resourcesData.idTypes![i].id.toString()) {
      //         return SavedData.resourcesData.idTypes![i].name.toString();
      //       }
      //     }
      //   } catch (e) {
      //     return '';
      //   }
      //   break;

      case 'signatures':
        try {
          for (int i = 0; i < SavedData.resourcesData.signatures!.length; i++) {
            if (id == SavedData.resourcesData.signatures![i].id.toString()) {
              return SavedData.resourcesData.signatures![i].name.toString();
            }
          }
        } catch (e) {
          return '';
        }
        break;

      case 'trackType':
        try {
          for (int i = 0; i < SavedData.resourcesData.trackType!.length; i++) {
            if (id == SavedData.resourcesData.trackType![i].id.toString()) {
              return SavedData.resourcesData.trackType![i].name.toString();
            }
          }
        } catch (e) {
          return '';
        }
        break;

      case 'rowStatus':
        try {
          for (int i = 0; i < SavedData.resourcesData.rowStatus!.length; i++) {
            if (id == SavedData.resourcesData.rowStatus![i].id.toString()) {
              return SavedData.resourcesData.rowStatus![i].name.toString();
            }
          }
        } catch (e) {
          return '';
        }
        break;

      case 'packaging':
        try {
          for (int i = 0; i < SavedData.resourcesData.packaging!.length; i++) {
            if (id == SavedData.resourcesData.packaging![i].id.toString()) {
              return SavedData.resourcesData.packaging![i].name.toString();
            }
          }
        } catch (e) {
          return '';
        }
        break;

      case 'banks':
        try {
          for (int i = 0; i < SavedData.resourcesData.banks!.length; i++) {
            if (id == SavedData.resourcesData.banks![i].id.toString()) {
              return SavedData.resourcesData.banks![i].name.toString();
            }
          }
        } catch (e) {
          return '';
        }
        break;

      case 'province':
        try {
          for (int i = 0; i < SavedData.resourcesData.province!.length; i++) {
            if (id == SavedData.resourcesData.province![i].id.toString()) {
              return SavedData.resourcesData.province![i].name.toString();
            }
          }
        } catch (e) {
          return '';
        }
        break;

      case 'postpone':
        try {
          for (int i = 0; i < SavedData.resourcesData.postpone!.length; i++) {
            if (id == SavedData.resourcesData.postpone![i].id.toString()) {
              return SavedData.resourcesData.postpone![i].name.toString();
            }
          }
        } catch (e) {
          return '';
        }
        break;

      case 'zone':
        try {
          for (int i = 0; i < SavedData.resourcesData.city!.length; i++) {
            for (int j = 0;
                j < SavedData.resourcesData.city![i].neighborhoods!.length;
                j++) {
              if (id ==
                  SavedData.resourcesData.city![i].neighborhoods![j].id
                      .toString()) {
                return SavedData.resourcesData.city![i].neighborhoods![j].name
                    .toString();
              }
            }
          }
        } catch (e) {
          return '';
        }
        break;

      // case 'weight':
      //   try {
      //     for (int i = 0; i < SavedData.resourcesData.weight!.length; i++) {
      //       if (id == SavedData.resourcesData.weight![i].id.toString()) {
      //         return SavedData.resourcesData.weight![i].name.toString();
      //       }
      //     }
      //   } catch (e) {
      //     return '';
      //   }
      //   break;
      case 'cityFromNeighborhood':
        try {
          for (int i = 0; i < SavedData.resourcesData.city!.length; i++) {
            for(int j = 0 ; j <SavedData.resourcesData.city![i].neighborhoods!.length ; j ++){
              if(id == SavedData.resourcesData.city![i].neighborhoods![j].id.toString()){
                return SavedData.resourcesData.city![i].name.toString() ;
              }
            }
          }
        } catch (e) {
          return '';
        }
        break;
    }
  }
}
