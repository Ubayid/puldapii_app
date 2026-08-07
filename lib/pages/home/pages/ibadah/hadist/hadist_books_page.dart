import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puldapii/config/bloc/hadist_bloc/hadist_bloc.dart';
import 'package:puldapii/pages/home/pages/ibadah/hadist/hadist_list_page.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/widget/header.dart';

class HadistBooksPage extends StatefulWidget {
  const HadistBooksPage({super.key});

  @override
  State<HadistBooksPage> createState() => _HadistBooksPageState();
}

class _HadistBooksPageState extends State<HadistBooksPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<HadistBloc>();
      if (bloc.state is HadistInitial) {
        bloc.add(FetchHadistBooks());
      }
    });
  }

  String _formatBookName(String value) {
    return value
        .split('_')
        .map(
          (word) =>
              word.isEmpty ? word : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            onNotifTap: () {
              debugPrint('Notif tapped');
            },
            onChatTap: () {
              debugPrint('Chat tapped');
            },
          ),
          Expanded(
            child: GradientPage(
              child: BlocBuilder<HadistBloc, HadistState>(
                builder: (context, state) {
                  List<String> books = [];
                  String? errorMessage;
                  bool isLoading = false;

                  if (state is HadistLoading) {
                    isLoading = true;
                  } else if (state is HadistLoaded) {
                    books = state.books;
                  } else if (state is HadistError) {
                    errorMessage = state.message;
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              errorMessage,
                              style: const TextStyle(fontSize: 13),
                            ),
                          )
                        else if (books.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Daftar kitab kosong'),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: books.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final book = books[index];

                              return InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          HadistListPage(book: book),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.92),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: Colors.teal.withOpacity(0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.menu_book_rounded,
                                          color: Colors.teal,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _formatBookName(book),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
