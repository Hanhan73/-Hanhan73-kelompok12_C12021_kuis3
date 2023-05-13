import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App P2P',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => JenisPinjamanCubit(),
        child: JenisPinjamanPage(),
      ),
    );
  }
}

class JenisPinjamanCubit extends Cubit<JenisPinjamanState> {
  int? selectedJenis;
  String? selectedJenisText;

  JenisPinjamanCubit()
      : selectedJenis = 1,
        selectedJenisText = 'Pilih Jenis Pinjaman',
        super(JenisPinjamanInitial());

  void updateSelectedJenis(int jenis) {
    selectedJenis = jenis;
    selectedJenisText = _getSelectedJenisPinjamanText(jenis);
    emit(JenisPinjamanUpdated(jenis));
  }

  Future<void> fetchJenisPinjaman(int jenis) async {
    emit(JenisPinjamanLoading());
    try {
      final response = await http
          .get(Uri.parse('http://178.128.17.76:8000/jenis_pinjaman/$jenis'));
      print(response.body);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData.containsKey('data')) {
          final dataList = jsonData['data'];
          if (dataList is List<dynamic>) {
            final jenisPinjaman =
                dataList.map((data) => JenisPinjaman.fromJson(data)).toList();
            emit(JenisPinjamanLoaded(jenisPinjaman));
          } else {
            emit(JenisPinjamanError('Invalid JSON data'));
          }
        } else {
          emit(JenisPinjamanError('Invalid JSON data'));
        }
      } else {
        emit(JenisPinjamanError('Failed to load jenis pinjaman'));
      }
    } catch (e) {
      emit(JenisPinjamanError(e.toString()));
    }
  }

  Future<void> fetchDetilJenisPinjaman(String id) async {
    emit(JenisPinjamanLoadingDetil());
    try {
      final response = await http
          .get(Uri.parse('http://178.128.17.76:8000/detil_jenis_pinjaman/$id'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final detilJenisPinjaman = DetilJenisPinjaman.fromJson(jsonData);
        emit(JenisPinjamanLoadedDetil(detilJenisPinjaman));
      } else {
        emit(JenisPinjamanError('Failed to load detil jenis pinjaman'));
      }
    } catch (e) {
      emit(JenisPinjamanError(e.toString()));
    }
  }

  String _getSelectedJenisPinjamanText(int jenis) {
    if (jenis == 1) {
      return 'Jenis Pinjaman 1';
    } else if (jenis == 2) {
      return 'Jenis Pinjaman 2';
    } else if (jenis == 3) {
      return 'Jenis Pinjaman 3';
    }
    return '';
  }
}

@override
class JenisPinjamanUpdated extends JenisPinjamanState {
  final int jenis;

  JenisPinjamanUpdated(this.jenis);
}

abstract class JenisPinjamanState {}

class JenisPinjamanInitial extends JenisPinjamanState {}

class JenisPinjamanLoading extends JenisPinjamanState {}

class JenisPinjamanError extends JenisPinjamanState {
  final String message;

  JenisPinjamanError(this.message);
}

class JenisPinjamanLoaded extends JenisPinjamanState {
  final List<JenisPinjaman> jenisPinjaman;

  JenisPinjamanLoaded(this.jenisPinjaman);
}

class JenisPinjamanLoadingDetil extends JenisPinjamanState {}

class JenisPinjamanLoadedDetil extends JenisPinjamanState {
  final DetilJenisPinjaman detilJenisPinjaman;

  JenisPinjamanLoadedDetil(this.detilJenisPinjaman);
}

class JenisPinjamanPage extends StatefulWidget {
  @override
  _JenisPinjamanPageState createState() => _JenisPinjamanPageState();
}

class _JenisPinjamanPageState extends State<JenisPinjamanPage> {
  String? selectedJenisPinjaman;
  late JenisPinjamanCubit jenisPinjamanCubit;

  String _getSelectedJenisPinjamanText() {
    if (jenisPinjamanCubit.selectedJenisText != null) {
      return jenisPinjamanCubit.selectedJenisText!;
    }
    return 'Pilih jenis pinjaman';
  }

  @override
  void initState() {
    super.initState();
    jenisPinjamanCubit = BlocProvider.of<JenisPinjamanCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('My App P2P'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                  '2105879, Farhan Muzhaffar Tiras Putra; 2100991, Khana Yusdiana; Saya berjanji tidak akan curang atau membantu orang lain berbuat curang'),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButton<int>(
                  value: jenisPinjamanCubit.selectedJenis,
                  hint: Text(_getSelectedJenisPinjamanText()),
                  onChanged: (value) {
                    jenisPinjamanCubit.updateSelectedJenis(value!);
                    jenisPinjamanCubit.fetchJenisPinjaman(value);
                  },
                  items: [
                    DropdownMenuItem<int>(
                      value: 1,
                      child: Text('Jenis Pinjaman 1'),
                    ),
                    DropdownMenuItem<int>(
                      value: 2,
                      child: Text('Jenis Pinjaman 2'),
                    ),
                    DropdownMenuItem<int>(
                      value: 3,
                      child: Text('Jenis Pinjaman 3'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              BlocBuilder<JenisPinjamanCubit, JenisPinjamanState>(
                builder: (context, state) {
                  if (state is JenisPinjamanLoading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is JenisPinjamanError) {
                    return Center(
                      child: Text(state.message),
                    );
                  } else if (state is JenisPinjamanLoaded) {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: state.jenisPinjaman.length,
                        itemBuilder: (context, index) {
                          final jenisPinjaman = state.jenisPinjaman[index];
                          return ListTile(
                            title: Text(jenisPinjaman.nama),
                            subtitle: Text("Id: " + jenisPinjaman.id),
                            onTap: () {
                              jenisPinjamanCubit
                                  .fetchDetilJenisPinjaman(jenisPinjaman.id);
                            },
                          );
                        },
                      ),
                    );
                  } else if (state is JenisPinjamanLoadingDetil) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is JenisPinjamanLoadedDetil) {
                    final detilJenisPinjaman = state.detilJenisPinjaman;
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detil Jenis Pinjaman',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('ID: ${detilJenisPinjaman.id}'),
                          SizedBox(height: 8),
                          Text('Nama: ${detilJenisPinjaman.nama}'),
                          SizedBox(height: 8),
                          Text('Bunga: ${detilJenisPinjaman.bunga}'),
                          SizedBox(height: 8),
                          Text('Syariah: ${detilJenisPinjaman.is_syariah}'),
                        ],
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ],
          ),
        ));
  }
}

class JenisPinjaman {
  final String id;
  final String nama;

  JenisPinjaman({required this.id, required this.nama});

  factory JenisPinjaman.fromJson(Map<String, dynamic> json) {
    return JenisPinjaman(
      id: json['id'],
      nama: json['nama'],
    );
  }
}

class DetilJenisPinjaman {
  final String id;
  final String nama;
  final String bunga;
  final String is_syariah;

  DetilJenisPinjaman(
      {required this.id,
      required this.nama,
      required this.bunga,
      required this.is_syariah});

  factory DetilJenisPinjaman.fromJson(Map<String, dynamic> json) {
    return DetilJenisPinjaman(
      id: json['id'],
      nama: json['nama'],
      bunga: json['bunga'],
      is_syariah: json['is_syariah'],
    );
  }
}
