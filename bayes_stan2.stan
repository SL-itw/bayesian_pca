//
// This Stan program defines a simple model, with a
// vector of values 'y' modeled as normally distributed
// with mean 'mu' and standard deviation 'sigma'.
//
// Learn more about model development with Stan at:
//
//    http://mc-stan.org/users/interfaces/rstan.html
//    https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
//

// The input data is a vector 'y' of length 'N'.
data {
  int<lower=0> N; //number of subjects
  int<lower=0> p; // number of covariates
  int<lower=0> q; // number of reduced PC of covariates
  matrix[N,p] x;//design matrix
  real a;
  real b;
}

// The parameters accepted by the model.
parameters {
   matrix[N, q] z; // The latent matrix
		matrix[p, q] B; // The weight matrix
	//	real<lower=0> tau; // Noise term
		vector<lower=0>[q] alpha; // ARD prior
  vector[p] mu;
  //matrix[p,q] B;
  real<lower=0> sigma;
 // positive_ordered[q] z; the first will be the smallest
//  vector<lower = 0>[q] alpha;
}
transformed parameters{
 vector<lower=0>[q] t_alpha;
		real<lower=0> t_sigma;
                t_alpha = inv(sqrt(alpha));
                t_sigma = inv(sqrt(sigma));
}
// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
  sigma ~ gamma(1,1);
  to_vector(z) ~ normal(0,1);
  alpha ~ gamma(a,b);

  for(j in 1:q) B[,j] ~ normal(0, t_alpha[j]);
	to_vector(x) ~ normal(to_vector(z*B'), t_sigma);

}generated quantities{
  matrix[N,p] preds;

  for(i in 1:p){
    for(j in 1:N){
    preds[j,i] = normal_rng((B[i,:]*z[j]'),t_sigma);
    }
  }

}

