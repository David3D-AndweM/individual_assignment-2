import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/swap_entity.dart';
import '../../../../shared/providers/swaps_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../widgets/swap_card.dart';

class MyOffersScreen extends StatefulWidget {
  const MyOffersScreen({super.key});

  @override
  State<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        context.read<SwapsProvider>().loadSwapsForUser(authProvider.currentUser!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Offers'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Received'),
            Tab(text: 'Sent'),
            Tab(text: 'Accepted'),
          ],
        ),
      ),
      body: Consumer2<SwapsProvider, AuthProvider>(
        builder: (context, swapsProvider, authProvider, child) {
          if (authProvider.currentUser == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.login,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Please log in to view your offers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          if (swapsProvider.isLoading && swapsProvider.swaps.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (swapsProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading offers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    swapsProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => swapsProvider.loadSwapsForUser(
                      authProvider.currentUser!.id,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final userId = authProvider.currentUser!.id;
          final receivedOffers = swapsProvider.getPendingReceivedSwaps(userId);
          final sentOffers = swapsProvider.getPendingSentSwaps(userId);
          final acceptedOffers = swapsProvider.getAcceptedSwaps(userId);

          return TabBarView(
            controller: _tabController,
            children: [
              // Received Offers Tab
              _buildOffersTab(
                offers: receivedOffers,
                emptyMessage: 'No offers received yet',
                emptySubtitle: 'When someone wants to swap your books, offers will appear here',
                currentUserId: userId,
                swapsProvider: swapsProvider,
              ),
              // Sent Offers Tab
              _buildOffersTab(
                offers: sentOffers,
                emptyMessage: 'No offers sent yet',
                emptySubtitle: 'Browse books and send swap offers to get started',
                currentUserId: userId,
                swapsProvider: swapsProvider,
              ),
              // Accepted Offers Tab
              _buildOffersTab(
                offers: acceptedOffers,
                emptyMessage: 'No accepted offers yet',
                emptySubtitle: 'Accepted swap offers will appear here',
                currentUserId: userId,
                swapsProvider: swapsProvider,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOffersTab({
    required List<SwapEntity> offers,
    required String emptyMessage,
    required String emptySubtitle,
    required String currentUserId,
    required SwapsProvider swapsProvider,
  }) {
    if (offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.swap_horiz_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              emptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        swapsProvider.loadSwapsForUser(currentUserId);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SwapCard(
              swap: offer,
              currentUserId: currentUserId,
              onTap: () => _handleOfferTap(offer, currentUserId, swapsProvider),
            ),
          );
        },
      ),
    );
  }

  void _handleOfferTap(
    SwapEntity offer,
    String currentUserId,
    SwapsProvider swapsProvider,
  ) {
    swapsProvider.showSwapActionDialog(
      context: context,
      swap: offer,
      currentUserId: currentUserId,
    );
  }
}
