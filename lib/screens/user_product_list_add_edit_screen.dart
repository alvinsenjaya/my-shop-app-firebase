import 'package:flutter/material.dart';
import 'package:my_shop_app/models/auth.dart';
import 'package:my_shop_app/models/product.dart';
import 'package:my_shop_app/screens/user_product_list_manager_screen.dart';
import 'package:provider/provider.dart';

class UserProductAddEditScreen extends StatefulWidget {
  static const routeName = '/user-products-edit';

  final Product _product;

  const UserProductAddEditScreen(this._product);

  @override
  _UserProductAddEditScreenState createState() =>
      _UserProductAddEditScreenState();
}

class _UserProductAddEditScreenState extends State<UserProductAddEditScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();

  bool _isLoading = false;

  void _updateImageListener() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  void _saveForm() async {
    if (!_form.currentState.validate()) return;

    setState(() {
      _isLoading = true;
    });

    if (widget._product != null) {
      try {
        await Product.updateById(
          title: _titleController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          imageUrl: _imageUrlController.text,
          id: widget._product.id,
          token: Provider.of<Auth>(context, listen: false).token,
        );
        Navigator.of(context)
            .pushReplacementNamed(UserProductListManagerScreen.routeName);
      } catch (error) {
        showDialog<Null>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error Occurred'),
              content: Text(error.toString()),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(
                        UserProductListManagerScreen.routeName);
                  },
                  child: Text('Ok'),
                ),
              ],
            );
          },
        );
      }

      return;
    }

    try {
      await Product.create(
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        imageUrl: _imageUrlController.text,
        token: Provider.of<Auth>(context, listen: false).token,
        userId: Provider.of<Auth>(context, listen: false).userId,
      );

      setState(() {
        _isLoading = false;
      });

      Navigator.of(context)
          .pushReplacementNamed(UserProductListManagerScreen.routeName);
    } catch (error) {
      showDialog<Null>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error Occurred'),
            content: Text(error.toString()),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Ok'),
              ),
            ],
          );
        },
      );
      throw error;
    }
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageListener);

    if (widget._product != null) {
      _titleController.text = widget._product.title;
      _priceController.text = widget._product.price.toString();
      _descriptionController.text = widget._product.description;
      _imageUrlController.text = widget._product.imageUrl;
    }

    super.initState();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageListener);
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Information'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      validator: (value) {
                        if (value.isEmpty) return 'This field is required';
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      controller: _titleController,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Price',
                      ),
                      validator: (value) {
                        if (value.isEmpty) return 'This field is required';
                        if (double.tryParse(value) == null)
                          return 'Please provide price in number';
                        if (double.parse(value) <= 0)
                          return 'Price have to be greater than 0';
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      controller: _priceController,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                      validator: (value) {
                        if (value.isEmpty) return 'This field is required';
                        return null;
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      textInputAction: TextInputAction.next,
                      controller: _descriptionController,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Image Url',
                            ),
                            validator: (value) {
                              if (value.isEmpty)
                                return 'This field is required';
                              if (!value.startsWith('http'))
                                return 'Invalid url';
                              return null;
                            },
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 30, left: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Center(
                                  child: Text(
                                  'Enter Image URL',
                                  textAlign: TextAlign.center,
                                ))
                              : Image.network(_imageUrlController.text,
                                  fit: BoxFit.cover),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    RaisedButton(
                      onPressed: () {
                        _saveForm();
                      },
                      color: Theme.of(context).primaryColorLight,
                      child: Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
