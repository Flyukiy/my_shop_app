import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../providers/product.dart';

class EditProductScreen extends StatefulWidget {
  static final routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var isInit = true;
  var isLoading = false;

  var _editedData = Product(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedData = Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedData.title,
          'description': _editedData.description,
          'price': _editedData.price.toString(),
          // 'imageUrl': _editedData.imageUrl,
        };
        _imageUrlController.text = _editedData.imageUrl;
      }
    }
    isInit = false;
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  void _saveForm() {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return null;
    }
    setState(() {
      isLoading = true;
    });

    _form.currentState.save();
    if (_editedData.id == null) {
      Provider.of<Products>(context, listen: false).addProduct(_editedData).then((_) {
        setState(() {
          isLoading = true;
        });
        Navigator.of(context).pop();
      });
    } else {
      Provider.of<Products>(context, listen: false).updateProduct(_editedData.id, _editedData);
      setState(() {
        isLoading = true;
      });
      Navigator.of(context).pop();
    }
    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: isLoading ? Center(child: CircularProgressIndicator(),) : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                initialValue: _initValues['title'],
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a value.';
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                onSaved: (value) {
                  _editedData = Product(
                    title: value,
                    imageUrl: _editedData.imageUrl,
                    description: _editedData.description,
                    id: _editedData.id,
                    isFavorite: _editedData.isFavorite,
                    price: _editedData.price,
                  );
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                initialValue: _initValues['price'],
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a price.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid price';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Please enter number greater than zero';
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
                onSaved: (value) {
                  _editedData = Product(
                    title: _editedData.title,
                    imageUrl: _editedData.imageUrl,
                    description: _editedData.description,
                    id: _editedData.id,
                    isFavorite: _editedData.isFavorite,
                    price: double.parse(value),
                  );
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                initialValue: _initValues['description'],
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.next,
                focusNode: _descriptionFocusNode,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a value';
                  }
                  if (value.length <= 10) {
                    return 'Should be at least ten character';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedData = Product(
                    title: _editedData.title,
                    imageUrl: _editedData.imageUrl,
                    description: value,
                    id: _editedData.id,
                    price: _editedData.price,
                    isFavorite: _editedData.isFavorite,
                  );
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(top: 8, right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey),
                    ),
                    child: _imageUrlController.text.isEmpty
                        ? Text(
                            'Enter URL',
                            textAlign: TextAlign.center,
                          )
                        : FittedBox(
                            child: Image.network(_imageUrlController.text),
                            fit: BoxFit.cover,
                          ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Image URL'),
                      // initialValue: _initValues['imageUrl'],
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageUrlController,
                      focusNode: _imageUrlFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter image URL';
                        }
                        if (!value.startsWith('http')) {
                          return 'Please enter valid URL';
                        }
                        // if (!value.endsWith('jpg') ||
                        //     !value.endsWith('png')) {
                        //   return 'Entered URL does not contain valid picture';
                        // }
                        return null;
                      },
                      onEditingComplete: () {
                        setState(() {});
                      },
                      onFieldSubmitted: (_) {
                        _saveForm();
                      },
                      onSaved: (value) {
                        _editedData = Product(
                          title: _editedData.title,
                          imageUrl: value,
                          description: _editedData.description,
                          id: _editedData.id,
                          price: _editedData.price,
                          isFavorite: _editedData.isFavorite
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
