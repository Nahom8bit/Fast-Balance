import 'package:flutter/material.dart';
import 'enhanced_loading.dart';
import 'modern_cards.dart';
import 'enhanced_forms.dart';
import 'enhanced_states.dart';

/// Demo screen to showcase enhanced UI components
class UIDemoScreen extends StatefulWidget {
  const UIDemoScreen({super.key});

  @override
  State<UIDemoScreen> createState() => _UIDemoScreenState();
}

class _UIDemoScreenState extends State<UIDemoScreen> {
  int _currentTab = 0;
  bool _showLoading = false;
  bool _showError = false;
  bool _showSuccess = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced UI Components Demo'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _buildCurrentTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildTabButton('Loading', 0),
          const SizedBox(width: 8),
          _buildTabButton('Cards', 1),
          const SizedBox(width: 8),
          _buildTabButton('Forms', 2),
          const SizedBox(width: 8),
          _buildTabButton('States', 3),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _currentTab == index;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => setState(() => _currentTab = index),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected 
            ? Theme.of(context).colorScheme.primary 
            : Theme.of(context).colorScheme.surface,
          foregroundColor: isSelected 
            ? Colors.white 
            : Theme.of(context).colorScheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentTab) {
      case 0:
        return _buildLoadingDemo();
      case 1:
        return _buildCardsDemo();
      case 2:
        return _buildFormsDemo();
      case 3:
        return _buildStatesDemo();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLoadingDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enhanced Loading States',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Skeleton Cards
          Text(
            'Skeleton Cards',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: EnhancedLoading.skeletonCard()),
              const SizedBox(width: 16),
              Expanded(child: EnhancedLoading.skeletonKPICard()),
            ],
          ),
          const SizedBox(height: 24),

          // Skeleton List Items
          Text(
            'Skeleton List Items',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(3, (index) => EnhancedLoading.skeletonListItem()),
          ),
          const SizedBox(height: 24),

          // Skeleton Form Fields
          Text(
            'Skeleton Form Fields',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(2, (index) => EnhancedLoading.skeletonFormField()),
          ),
          const SizedBox(height: 24),

          // Progress Indicator
          Text(
            'Progress Indicator',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          EnhancedLoading.progressIndicator(
            progress: 0.7,
            label: 'Upload Progress',
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),

          // Loading Overlay Demo
          Text(
            'Loading Overlay',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() => _showLoading = true),
            child: const Text('Show Loading Overlay'),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Modern Card Components',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Modern Card
          Text(
            'Modern Card',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ModernCard(
            title: 'Sample Card',
            icon: Icons.star,
            accentColor: Colors.blue,
            onTap: () => _showSnackBar('Card tapped!'),
            child: const Text('This is a modern card with enhanced styling and interactions.'),
          ),
          const SizedBox(height: 24),

          // Modern KPI Card
          Text(
            'Modern KPI Card',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ModernKPICard(
            title: 'Total Sales',
            value: 125000.0,
            change: 12.5,
            icon: Icons.trending_up,
            color: Colors.green,
            onTap: () => _showSnackBar('KPI card tapped!'),
          ),
          const SizedBox(height: 24),

          // Row of KPI Cards
          Text(
            'KPI Cards Row',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ModernKPICard(
                  title: 'Revenue',
                  value: 85000.0,
                  change: 8.2,
                  icon: Icons.attach_money,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ModernKPICard(
                  title: 'Orders',
                  value: 1250.0,
                  change: -3.1,
                  icon: Icons.shopping_cart,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormsDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enhanced Form Components',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Enhanced Form Section
          EnhancedFormSection(
            title: 'Business Information',
            description: 'Enter your business details below',
            icon: Icons.business,
            accentColor: Colors.blue,
            children: [
              EnhancedTextField(
                label: 'Business Name',
                hint: 'Enter your business name',
                controller: TextEditingController(),
                isRequired: true,
                prefixIcon: const Icon(Icons.business),
              ),
              const SizedBox(height: 16),
              EnhancedTextField(
                label: 'Email Address',
                hint: 'Enter your email address',
                controller: TextEditingController(),
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email),
              ),
              const SizedBox(height: 16),
              EnhancedDropdownField<String>(
                label: 'Business Type',
                value: 'retail',
                items: const [
                  DropdownMenuItem(value: 'retail', child: Text('Retail')),
                  DropdownMenuItem(value: 'wholesale', child: Text('Wholesale')),
                  DropdownMenuItem(value: 'service', child: Text('Service')),
                ],
                onChanged: (value) => _showSnackBar('Selected: $value'),
                prefixIcon: const Icon(Icons.category),
              ),
              const SizedBox(height: 16),
              EnhancedSwitchField(
                label: 'Enable Notifications',
                subtitle: 'Receive updates about your business',
                value: true,
                onChanged: (value) => _showSnackBar('Notifications: $value'),
                icon: Icons.notifications,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatesDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enhanced State Components',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _showLoading = true),
                  child: const Text('Show Loading'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _showError = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Show Error'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _showSuccess = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Show Success'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // State Examples
          if (_showLoading)
            EnhancedLoadingState(
              message: 'Loading your data...',
              showProgress: true,
              progress: 0.6,
            ),
          
          if (_showError)
            EnhancedErrorState(
              title: 'Something went wrong',
              message: 'We encountered an error while processing your request. Please try again.',
              onRetry: () => setState(() => _showError = false),
              errorCode: 'ERR_001',
            ),
          
          if (_showSuccess)
            EnhancedSuccessState(
              title: 'Success!',
              message: 'Your data has been saved successfully.',
              onAction: () => setState(() => _showSuccess = false),
            ),

          if (!_showLoading && !_showError && !_showSuccess) ...[
            // Empty State
            EnhancedEmptyState(
              title: 'No Data Available',
              message: 'There are no items to display at the moment. Get started by adding your first item.',
              icon: Icons.inbox_outlined,
              onAction: () => _showSnackBar('Add item action'),
              actionLabel: 'Add Item',
            ),
            const SizedBox(height: 24),

            // Network Error State
            EnhancedNetworkErrorState(
              onRetry: () => _showSnackBar('Retrying connection...'),
            ),
            const SizedBox(height: 24),

            // Permission Error State
            EnhancedPermissionErrorState(
              onAction: () => _showSnackBar('Requesting access...'),
            ),
          ],
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
