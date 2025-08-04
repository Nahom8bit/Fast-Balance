import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Comprehensive error boundary widget for graceful error handling
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context, Object error, StackTrace? stackTrace)? errorBuilder;
  final VoidCallback? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    FlutterError.onError = _handleFlutterError;
  }

  void _handleFlutterError(FlutterErrorDetails details) {
    setState(() {
      _error = details.exception;
      _stackTrace = details.stack;
    });
    
    widget.onError?.call();
    
    if (kDebugMode) {
      print('ErrorBoundary caught error: ${details.exception}');
      print('StackTrace: ${details.stack}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(context, _error!, _stackTrace) ??
          _buildDefaultErrorWidget(context);
    }

    return widget.child;
  }

  Widget _buildDefaultErrorWidget(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We encountered an unexpected error. Please try again or contact support if the problem persists.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _retry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: _goBack,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                ],
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 24),
                ExpansionTile(
                  title: const Text('Error Details (Debug)'),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Error: $_error',
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                          if (_stackTrace != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'StackTrace: $_stackTrace',
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _retry() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    FlutterError.onError = FlutterError.presentError;
    super.dispose();
  }
}

/// Error widget for specific error states
class ErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;
  final IconData? icon;

  const ErrorWidget({
    super.key,
    required this.title,
    required this.message,
    this.details,
    this.onRetry,
    this.onGoBack,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (details != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  details!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
            if (onRetry != null || onGoBack != null) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onRetry != null) ...[
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                  if (onRetry != null && onGoBack != null) ...[
                    const SizedBox(width: 16),
                  ],
                  if (onGoBack != null) ...[
                    OutlinedButton.icon(
                      onPressed: onGoBack,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Go Back'),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Network error widget
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorWidget(
      title: 'Network Error',
      message: 'Unable to connect to the server. Please check your internet connection and try again.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }
}

/// Data loading error widget
class DataLoadingErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const DataLoadingErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorWidget(
      title: 'Data Loading Error',
      message: message,
      icon: Icons.data_usage,
      onRetry: onRetry,
    );
  }
}

/// Permission error widget
class PermissionErrorWidget extends StatelessWidget {
  final String permission;
  final VoidCallback? onRetry;

  const PermissionErrorWidget({
    super.key,
    required this.permission,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorWidget(
      title: 'Permission Required',
      message: 'This app needs $permission permission to function properly. Please grant the permission and try again.',
      icon: Icons.security,
      onRetry: onRetry,
    );
  }
} 