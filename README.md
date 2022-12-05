# hjb_fno
Using a Fourier Neural Operator to learn Solution-Mapping Operators for Hamilton-Jacobi Bellman Equations


Results
- Train/test loss over epochs: bias/variance tradeoff
- Hyperparameter search on same plot
- Trajectory animation

- [ ] Get upscale working
-- training downsampled model has high train/test error...
-- maybe because it's missing the 0? (I think definitely)
---TRY: 1) goal state (instead of goal set)
---TRY: 2) 