import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seeds/v2/constants/app_colors.dart';
import 'package:seeds/models/models.dart';
import 'package:seeds/providers/notifiers/rate_notiffier.dart';
import 'package:seeds/providers/notifiers/settings_notifier.dart';
import 'package:seeds/providers/services/eos_service.dart';
import 'package:seeds/providers/services/firebase/firebase_database_map_keys.dart';
import 'package:seeds/providers/services/firebase/firebase_database_service.dart';
import 'package:seeds/v2/datasource/remote/firebase/firebase_datastore_service.dart';
import 'package:seeds/widgets/amount_field.dart';
import 'package:seeds/widgets/circle_avatar_factory.dart';
import 'package:seeds/widgets/main_button.dart';
import 'package:path/path.dart';
import 'package:seeds/i18n/wallet.i18n.dart';
import 'package:seeds/widgets/main_text_field.dart';
import 'package:seeds/utils/double_extension.dart';

class ProductsCatalog extends StatefulWidget {
  const ProductsCatalog();

  @override
  _ProductsCatalogState createState() => _ProductsCatalogState();
}

class _ProductsCatalogState extends State<ProductsCatalog> {
  final editKey = GlobalKey<FormState>();
  final priceKey = GlobalKey<FormState>();
  final nameKey = GlobalKey<FormState>();
  var savingLoader = GlobalKey<MainButtonState>();

  String? editProductName = "";
  double? editPriceValue = 0;
  String? editCurrency = SEEDS;
  String editLocalImagePath = '';

  @override
  void initState() {
    super.initState();
  }

  void chooseProductPicture() async {
    final PickedFile? image = await ImagePicker().getImage(source: ImageSource.gallery, imageQuality: 20);

    if (image == null) {
      return;
    }

    File localImage = File(image.path);

    final String path = (await getApplicationDocumentsDirectory()).path;
    final fileName = basename(image.path);
    final fileExtension = extension(image.path);

    localImage = await localImage.copy("$path/$fileName$fileExtension");

    setState(() {
      editLocalImagePath = localImage.path;
    });
  }

  bool productNameExists(String? name) {
    return products.indexWhere((element) => element.data()!['name'] == editProductName) != -1;
  }

  Future<void> createNewProduct(String? userAccount, BuildContext context) async {
    if (productNameExists(editProductName)) {
      return;
    }

    String? downloadUrl;

    setState(() {
      savingLoader.currentState!.loading();
    });

    if (editLocalImagePath.isNotEmpty) {
      TaskSnapshot image = await FirebaseDataStoreService().uploadPic(File(editLocalImagePath), userAccount!);
      downloadUrl = await image.ref.getDownloadURL();
      editLocalImagePath = '';
    }

    final product = ProductModel(
      name: editProductName,
      price: editPriceValue,
      picture: downloadUrl,
      currency: editCurrency,
      position: products.length,
    );

    await FirebaseDatabaseService().createProduct(product, userAccount).then((value) => closeBottomSheet(context));
  }

  Future<void> editProduct(ProductModel productModel, String? userAccount, BuildContext context) async {
    String? downloadUrl;

    setState(() {
      savingLoader.currentState!.loading();
    });

    if (editLocalImagePath.isNotEmpty) {
      TaskSnapshot image = await FirebaseDataStoreService().uploadPic(File(editLocalImagePath), userAccount!);
      downloadUrl = await image.ref.getDownloadURL();
      editLocalImagePath = '';
    }

    final product = ProductModel(
        name: editProductName,
        price: editPriceValue,
        picture: downloadUrl,
        id: productModel.id,
        currency: editCurrency);

    await FirebaseDatabaseService().updateProduct(product, userAccount).then((value) => closeBottomSheet(context));
  }

  void closeBottomSheet(BuildContext context) {
    Navigator.pop(context);
    setState(() {});
  }

  void deleteProduct(ProductModel productModel, String? userAccount) {
    FirebaseDatabaseService().deleteProduct(productModel, userAccount);
  }

  Future<void> showDeleteProduct(BuildContext context, ProductModel productModel, String? userAccount) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete'.i18n + " ${productModel.name} ?"),
          actions: [
            MaterialButton(
              child: Text("Delete".i18n),
              onPressed: () {
                deleteProduct(productModel, userAccount);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildPictureWidget(String? imageUrl) {
    var children;
    if (editLocalImagePath.isNotEmpty) {
      children = [
        CircleAvatar(
          backgroundImage: FileImage(File(editLocalImagePath)),
          radius: 20,
        ),
        const SizedBox(width: 10),
        Text("Change Picture".i18n),
      ];
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      children = [
        CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
          radius: 20,
        ),
        const SizedBox(width: 10),
        Text('Change Picture'.i18n),
      ];
    } else {
      children = [
        const CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(
            Icons.add,
            color: Colors.black,
            size: 15,
          ),
          radius: 15,
        ),
        Text('Add Picture'.i18n),
      ];
    }

    return Container(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ));
  }

  void showEditProduct(BuildContext context, ProductModel productModel, String? userAccount) {
    editCurrency = productModel.currency;
    editProductName = productModel.name;
    editPriceValue = productModel.price;
    editLocalImagePath = "";

    var fiatCurrency = editCurrency != SEEDS ? editCurrency : SettingsNotifier.of(context).selectedFiatCurrency;

    showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    blurRadius: 16,
                    color: AppColors.blue,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Form(
                key: editKey,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  child: Wrap(
                    runSpacing: 10.0,
                    children: <Widget>[
                      DottedBorder(
                        color: AppColors.grey,
                        strokeWidth: 1,
                        child: GestureDetector(
                          onTap: chooseProductPicture,
                          child: buildPictureWidget(productModel.picture),
                        ),
                      ),
                      MainTextField(
                          labelText: 'Name'.i18n,
                          initialValue: productModel.name,
                          validator: (String name) {
                            String? error;
                            if (editProductName == null || editProductName == "") {
                              error = 'Name cannot be empty x'.i18n;
                            }
                            return error;
                          },
                          onChanged: (name) {
                            editProductName = name;
                            editKey.currentState!.validate();
                          }),
                      AmountField(
                          currentCurrency: editCurrency,
                          fiatCurrency: fiatCurrency,
                          initialValue: productModel.price,
                          autoFocus: false,
                          hintText: "Price",
                          onChanged: (seedsAmount, fieldAmount, selectedCurrency) => {
                                editPriceValue = fieldAmount,
                                editCurrency = selectedCurrency,
                              }),
                      MainButton(
                        key: savingLoader,
                        title: 'Done'.i18n,
                        onPressed: () {
                          if (editKey.currentState!.validate()) {
                            editProduct(productModel, userAccount, context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });

    setState(() {});
  }

  void showNewProduct(BuildContext context, String? accountName) {
    editCurrency = SEEDS;
    editProductName = "";
    editPriceValue = 0;
    editLocalImagePath = "";

    showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    blurRadius: 16,
                    color: AppColors.blue,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                child: Wrap(
                  runSpacing: 10.0,
                  children: <Widget>[
                    DottedBorder(
                      color: AppColors.grey,
                      strokeWidth: 1,
                      child: GestureDetector(
                        onTap: chooseProductPicture,
                        child: buildPictureWidget(null),
                      ),
                    ),
                    Form(
                      key: nameKey,
                      child: MainTextField(
                          labelText: 'Name'.i18n,
                          initialValue: "",
                          validator: (String name) {
                            String? error;
                            if (editProductName == null || editProductName!.isEmpty) {
                              error = 'Name cannot be empty'.i18n;
                            }
                            return error;
                          },
                          onChanged: (name) {
                            editProductName = name;
                            nameKey.currentState!.validate();
                          }),
                    ),
                    Form(
                      key: priceKey,
                      child: AmountField(
                          currentCurrency: editCurrency,
                          fiatCurrency: SettingsNotifier.of(context).selectedFiatCurrency,
                          autoFocus: false,
                          hintText: "Price",
                          onChanged: (amount, fieldAmount, currencyInput) {
                            editPriceValue = fieldAmount;
                            editCurrency = currencyInput;
                          }),
                    ),
                    MainButton(
                      key: savingLoader,
                      title: 'Add Product'.i18n,
                      onPressed: () {
                        if (priceKey.currentState!.validate() && nameKey.currentState!.validate()) {
                          createNewProduct(accountName, context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
    setState(() {});
  }

  late List<DocumentSnapshot> products;
  Future? reordering;

  @override
  Widget build(BuildContext context) {
    var accountName = EosService.of(context, listen: false).accountName;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Your Products'.i18n,
          style: const TextStyle(color: Colors.black87),
        ),
      ),
      floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
                backgroundColor: AppColors.blue,
                onPressed: () => showNewProduct(context, accountName),
                child: const Icon(Icons.add),
              )),
      body: FutureBuilder(builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.none || snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder<QuerySnapshot>(
              stream: FirebaseDatabaseService().getOrderedProductsForUser(accountName),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                } else {
                  products = snapshot.data!.docs;
                  return ReorderableListView(
                    onReorder: (oldIndex, newIndex) {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      products.insert(newIndex, products.removeAt(oldIndex));
                      final futures = <Future>[];
                      for (int i = 0; i < products.length; i++) {
                        futures.add(products[i].reference.update({
                          PRODUCT_POSITION_KEY: i,
                        }));
                      }
                      setState(() {
                        reordering = Future.wait(futures);
                      });
                    },
                    children: products.map((data) {
                      var product = ProductModel.fromSnapshot(data as QueryDocumentSnapshot);
                      return ListTile(
                        key: Key(data.id),
                        leading: CircleAvatarFactory.buildProductAvatar(product),
                        title: Material(
                          child: Text(
                            product.name == null ? "" : product.name!,
                            style: const TextStyle(fontFamily: "worksans", fontWeight: FontWeight.w500),
                          ),
                        ),
                        subtitle: Material(
                          child: Text(
                            getProductPrice(product),
                            style: const TextStyle(fontFamily: "worksans", fontWeight: FontWeight.w400),
                          ),
                        ),
                        trailing: Builder(
                          builder: (context) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  setState(() {});

                                  showEditProduct(context, product, accountName);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDeleteProduct(context, product, accountName);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
              });
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      }),
    );
  }

  String getProductPrice(ProductModel product) {
    return "${product.price.seedsFormatted} ${product.currency}";
  }
}
